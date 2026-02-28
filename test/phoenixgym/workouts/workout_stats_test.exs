defmodule Phoenixgym.WorkoutStatsTest do
  use Phoenixgym.DataCase, async: true

  alias Phoenixgym.WorkoutStats
  alias Phoenixgym.Records
  alias Phoenixgym.Records.PersonalRecord
  alias Phoenixgym.Workouts
  alias Phoenixgym.Repo
  import Phoenixgym.Fixtures

  # Build a minimal workout-shaped map for pure logic tests (no DB).
  # workout_exercises: list of %{exercise_id, workout_sets: [%{id, weight, reps, is_completed}]}
  defp workout_with_sets(exercise_id, sets, opts \\ []) do
    finished_at = Keyword.get(opts, :finished_at, ~U[2024-01-15 12:00:00Z])

    %{
      finished_at: finished_at,
      workout_exercises: [
        %{
          exercise_id: exercise_id,
          workout_sets:
            Enum.with_index(sets, 1)
            |> Enum.map(fn {s, i} ->
              %{
                id: i,
                weight: s[:weight],
                reps: s[:reps] || 0,
                is_completed: s[:is_completed] != false
              }
            end)
        }
      ]
    }
  end

  describe "compute_prs/1 — max_weight" do
    test "identifies max_weight from completed sets" do
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("80"), reps: 10, is_completed: true},
          %{weight: Decimal.new("100"), reps: 5, is_completed: true},
          %{weight: Decimal.new("60"), reps: 12, is_completed: true}
        ])

      prs = WorkoutStats.compute_prs(workout)

      max_weight =
        Enum.find(prs, fn p -> p.record_type == "max_weight" and p.exercise_id == 1 end)

      assert max_weight != nil
      assert Decimal.equal?(max_weight.value, Decimal.new("100"))
    end

    test "ignores incomplete sets for max_weight" do
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("100"), reps: 5, is_completed: true},
          %{weight: Decimal.new("120"), reps: 5, is_completed: false}
        ])

      prs = WorkoutStats.compute_prs(workout)
      max_weight = Enum.find(prs, fn p -> p.record_type == "max_weight" end)
      assert Decimal.equal?(max_weight.value, Decimal.new("100"))
    end

    test "no max_weight when no completed sets" do
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("100"), reps: 5, is_completed: false}
        ])

      prs = WorkoutStats.compute_prs(workout)
      assert prs == []
    end
  end

  describe "compute_prs/1 — max_reps" do
    test "identifies max_reps from completed sets" do
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("60"), reps: 10, is_completed: true},
          %{weight: Decimal.new("60"), reps: 15, is_completed: true}
        ])

      prs = WorkoutStats.compute_prs(workout)
      max_reps = Enum.find(prs, fn p -> p.record_type == "max_reps" and p.exercise_id == 1 end)
      assert max_reps != nil
      assert Decimal.equal?(max_reps.value, Decimal.new(15))
    end
  end

  describe "compute_prs/1 — estimated_1rm" do
    test "uses Epley formula weight * (1 + reps/30)" do
      # 100 kg × 10 reps → 1RM = 100 * (1 + 10/30) = 100 * (4/3) ≈ 133.33
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("100"), reps: 10, is_completed: true}
        ])

      prs = WorkoutStats.compute_prs(workout)
      pr_1rm = Enum.find(prs, fn p -> p.record_type == "estimated_1rm" end)
      assert pr_1rm != nil

      expected =
        Decimal.mult(
          Decimal.new("100"),
          Decimal.add(Decimal.new(1), Decimal.div(Decimal.new(10), Decimal.new(30)))
        )

      assert Decimal.equal?(pr_1rm.value, expected)
    end

    test "picks the set with highest estimated 1RM when multiple sets" do
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("80"), reps: 12, is_completed: true},
          %{weight: Decimal.new("100"), reps: 5, is_completed: true}
        ])

      prs = WorkoutStats.compute_prs(workout)
      pr_1rm = Enum.find(prs, fn p -> p.record_type == "estimated_1rm" end)
      assert pr_1rm != nil
      # 100*(1+5/30) = 100*1.166.. = 116.67; 80*(1+12/30) = 80*1.4 = 112
      assert Decimal.compare(pr_1rm.value, Decimal.new("112")) == :gt
    end
  end

  describe "compute_prs/1 — max_volume_set" do
    test "identifies single set with highest weight×reps" do
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("100"), reps: 5, is_completed: true},
          %{weight: Decimal.new("60"), reps: 12, is_completed: true}
        ])

      prs = WorkoutStats.compute_prs(workout)
      max_vol = Enum.find(prs, fn p -> p.record_type == "max_volume_set" end)
      assert max_vol != nil
      # 100*5=500, 60*12=720
      assert Decimal.equal?(max_vol.value, Decimal.new(720))
    end
  end

  describe "compute_prs/1 — max_volume_session" do
    test "sums volume of all completed sets for the exercise" do
      workout =
        workout_with_sets(1, [
          %{weight: Decimal.new("100"), reps: 5, is_completed: true},
          %{weight: Decimal.new("80"), reps: 8, is_completed: true}
        ])

      prs = WorkoutStats.compute_prs(workout)
      session = Enum.find(prs, fn p -> p.record_type == "max_volume_session" end)
      assert session != nil
      # 500 + 640 = 1140
      assert Decimal.equal?(session.value, Decimal.new(1140))
    end
  end

  describe "compute_prs/1 — multiple exercises" do
    test "returns PRs per exercise" do
      workout = %{
        finished_at: ~U[2024-01-15 12:00:00Z],
        workout_exercises: [
          %{
            exercise_id: 10,
            workout_sets: [
              %{id: 1, weight: Decimal.new("80"), reps: 8, is_completed: true}
            ]
          },
          %{
            exercise_id: 20,
            workout_sets: [
              %{id: 2, weight: Decimal.new("50"), reps: 12, is_completed: true}
            ]
          }
        ]
      }

      prs = WorkoutStats.compute_prs(workout)
      ex10 = Enum.filter(prs, fn p -> p.exercise_id == 10 end)
      ex20 = Enum.filter(prs, fn p -> p.exercise_id == 20 end)
      assert length(ex10) == 5
      assert length(ex20) == 5

      assert Enum.any?(ex10, fn p ->
               p.record_type == "max_weight" and Decimal.equal?(p.value, Decimal.new("80"))
             end)

      assert Enum.any?(ex20, fn p ->
               p.record_type == "max_weight" and Decimal.equal?(p.value, Decimal.new("50"))
             end)
    end
  end

  describe "compute_prs/1 integration — finish workout with PR hook" do
    test "finish workout with new PR inserts personal_records row" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)

      Workouts.create_workout_set(we.id, 1, %{
        weight: "100.0",
        reps: 5,
        is_completed: true
      })

      workout = Workouts.get_workout!(workout.id)
      {:ok, _finished} = Workouts.finish_workout(workout)

      best = Records.get_best_records(exercise.id)
      assert Map.has_key?(best, "max_weight")
      assert Decimal.equal?(best["max_weight"].value, Decimal.new("100.0"))
    end

    test "finish second workout with lower weight does not create new PR row" do
      exercise = exercise_fixture()
      {:ok, w1} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(w1.id)
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, pos)
      Workouts.create_workout_set(we1.id, 1, %{weight: "100.0", reps: 5, is_completed: true})
      {:ok, _} = Workouts.finish_workout(Workouts.get_workout!(w1.id))

      count_after_first = Repo.aggregate(PersonalRecord, :count, :id)

      {:ok, w2} = Workouts.start_workout()
      pos2 = Workouts.next_exercise_position(w2.id)
      {:ok, we2} = Workouts.create_workout_exercise(w2.id, exercise.id, pos2)
      Workouts.create_workout_set(we2.id, 1, %{weight: "80.0", reps: 5, is_completed: true})
      {:ok, _} = Workouts.finish_workout(Workouts.get_workout!(w2.id))

      count_after_second = Repo.aggregate(PersonalRecord, :count, :id)
      assert count_after_second == count_after_first
    end

    test "finish third workout with higher weight inserts new PR row" do
      exercise = exercise_fixture()
      {:ok, w1} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(w1.id)
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, pos)
      Workouts.create_workout_set(we1.id, 1, %{weight: "100.0", reps: 5, is_completed: true})
      {:ok, _} = Workouts.finish_workout(Workouts.get_workout!(w1.id))

      {:ok, w2} = Workouts.start_workout()
      pos2 = Workouts.next_exercise_position(w2.id)
      {:ok, we2} = Workouts.create_workout_exercise(w2.id, exercise.id, pos2)
      Workouts.create_workout_set(we2.id, 1, %{weight: "120.0", reps: 5, is_completed: true})
      {:ok, _} = Workouts.finish_workout(Workouts.get_workout!(w2.id))

      best = Records.get_best_records(exercise.id)
      assert Decimal.compare(best["max_weight"].value, Decimal.new("120.0")) == :eq
    end
  end
end
