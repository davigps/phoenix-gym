defmodule Phoenixgym.RecordsTest do
  use Phoenixgym.DataCase, async: true

  alias Phoenixgym.Records
  alias Phoenixgym.Records.PersonalRecord
  alias Phoenixgym.Workouts
  import Phoenixgym.Fixtures

  @valid_attrs %{
    exercise_id: 1,
    record_type: "max_weight",
    value: Decimal.new("100.0"),
    achieved_at: ~U[2024-01-01 10:00:00Z]
  }

  # ── Changeset tests ──────────────────────────────────────────────────────

  describe "PersonalRecord.changeset/2" do
    test "valid attrs produce a valid changeset" do
      exercise = exercise_fixture()
      attrs = Map.put(@valid_attrs, :exercise_id, exercise.id)
      assert PersonalRecord.changeset(%PersonalRecord{}, attrs).valid?
    end

    test "exercise_id, record_type, value, and achieved_at are required" do
      errors = errors_on(PersonalRecord.changeset(%PersonalRecord{}, %{}))
      assert errors[:exercise_id] != nil
      assert errors[:record_type] != nil
      assert errors[:value] != nil
      assert errors[:achieved_at] != nil
    end

    test "invalid record_type is rejected" do
      exercise = exercise_fixture()

      attrs =
        @valid_attrs |> Map.put(:exercise_id, exercise.id) |> Map.put(:record_type, "best_set")

      errors = errors_on(PersonalRecord.changeset(%PersonalRecord{}, attrs))
      assert errors[:record_type] != nil
    end

    test "all valid record types are accepted" do
      exercise = exercise_fixture()

      for type <- PersonalRecord.record_types() do
        attrs = @valid_attrs |> Map.put(:exercise_id, exercise.id) |> Map.put(:record_type, type)
        cs = PersonalRecord.changeset(%PersonalRecord{}, attrs)
        assert cs.valid?, "expected record_type #{type} to be valid"
      end
    end

    test "value must be greater than 0" do
      exercise = exercise_fixture()

      attrs =
        @valid_attrs |> Map.put(:exercise_id, exercise.id) |> Map.put(:value, Decimal.new("0"))

      errors = errors_on(PersonalRecord.changeset(%PersonalRecord{}, attrs))
      assert errors[:value] != nil
    end

    test "workout_set_id is optional" do
      exercise = exercise_fixture()
      attrs = Map.put(@valid_attrs, :exercise_id, exercise.id)
      assert PersonalRecord.changeset(%PersonalRecord{}, attrs).valid?
    end
  end

  # ── Context tests ────────────────────────────────────────────────────────

  describe "Records context" do
    test "list_records_for_exercise/1 returns all PRs for an exercise" do
      %{workout: workout, exercise: exercise} = completed_workout_fixture()
      Records.compute_and_save_prs(workout)

      records = Records.list_records_for_exercise(exercise.id)
      assert length(records) > 0
      assert Enum.all?(records, &(&1.exercise_id == exercise.id))
    end

    test "list_records_for_exercise/1 returns empty list when no PRs" do
      exercise = exercise_fixture()
      assert Records.list_records_for_exercise(exercise.id) == []
    end

    test "get_best_records/1 returns map keyed by record_type" do
      %{workout: workout, exercise: exercise} = completed_workout_fixture()
      Records.compute_and_save_prs(workout)

      best = Records.get_best_records(exercise.id)
      assert is_map(best)
      assert Map.has_key?(best, "max_weight")
    end

    test "get_best_records/1 returns empty map when no PRs" do
      exercise = exercise_fixture()
      assert Records.get_best_records(exercise.id) == %{}
    end

    test "list_recent_records/1 returns most recent PRs" do
      %{workout: workout} = completed_workout_fixture()
      Records.compute_and_save_prs(workout)

      records = Records.list_recent_records(5)
      assert length(records) <= 5
    end

    test "list_prs_for_exercise/1 returns one row per record_type" do
      %{workout: _workout, exercise: exercise} = completed_workout_fixture()
      # finish_workout already calls compute_and_save_prs
      prs = Records.list_prs_for_exercise(exercise.id)
      record_types = Enum.map(prs, & &1.record_type) |> Enum.uniq()
      assert length(record_types) == length(prs)
      assert length(prs) <= 5
      assert Enum.all?(prs, &(&1.exercise_id == exercise.id))
    end

    test "list_prs_for_exercise/1 returns empty list when no PRs" do
      exercise = exercise_fixture()
      assert Records.list_prs_for_exercise(exercise.id) == []
    end

    test "get_recent_prs/1 returns latest N records ordered by achieved_at" do
      %{workout: _workout} = completed_workout_fixture()
      prs = Records.get_recent_prs(3)
      assert length(prs) <= 3

      if length(prs) >= 2 do
        [first | rest] = prs

        assert Enum.all?(rest, fn pr ->
                 DateTime.compare(pr.achieved_at, first.achieved_at) != :gt
               end)
      end
    end
  end

  # ── compute_and_save_prs tests ───────────────────────────────────────────

  describe "Records.compute_and_save_prs/1" do
    test "saves max_weight PR after workout" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)
      Workouts.create_workout_set(we.id, 1, %{weight: "120.0", reps: 5, is_completed: true})
      {:ok, finished} = Workouts.finish_workout(workout)

      Records.compute_and_save_prs(finished)

      best = Records.get_best_records(exercise.id)
      assert Map.has_key?(best, "max_weight")
      assert Decimal.equal?(best["max_weight"].value, Decimal.new("120.0"))
    end

    test "does not create PR when value is zero (no completed sets)" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)
      # Set is NOT completed
      Workouts.create_workout_set(we.id, 1, %{weight: "100.0", reps: 5, is_completed: false})
      {:ok, finished} = Workouts.finish_workout(workout)

      Records.compute_and_save_prs(finished)

      assert Records.get_best_records(exercise.id) == %{}
    end

    test "does not create new PR when existing record is higher" do
      exercise = exercise_fixture()

      # First workout — establishes PR
      {:ok, w1} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(w1.id)
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, pos)
      Workouts.create_workout_set(we1.id, 1, %{weight: "150.0", reps: 5, is_completed: true})
      {:ok, f1} = Workouts.finish_workout(w1)
      Records.compute_and_save_prs(f1)

      count_after_first = Repo.aggregate(PersonalRecord, :count, :id)

      # Second workout — lower weight, should not create new PR
      {:ok, w2} = Workouts.start_workout()
      pos2 = Workouts.next_exercise_position(w2.id)
      {:ok, we2} = Workouts.create_workout_exercise(w2.id, exercise.id, pos2)
      Workouts.create_workout_set(we2.id, 1, %{weight: "100.0", reps: 5, is_completed: true})
      {:ok, f2} = Workouts.finish_workout(w2)
      Records.compute_and_save_prs(f2)

      count_after_second = Repo.aggregate(PersonalRecord, :count, :id)
      assert count_after_second == count_after_first
    end

    test "saves new PR when it beats existing record" do
      exercise = exercise_fixture()

      # First workout
      {:ok, w1} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(w1.id)
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, pos)
      Workouts.create_workout_set(we1.id, 1, %{weight: "100.0", reps: 5, is_completed: true})
      {:ok, f1} = Workouts.finish_workout(w1)
      Records.compute_and_save_prs(f1)

      old_best = Records.get_best_records(exercise.id)

      # Second workout — heavier, should create new max_weight PR
      {:ok, w2} = Workouts.start_workout()
      pos2 = Workouts.next_exercise_position(w2.id)
      {:ok, we2} = Workouts.create_workout_exercise(w2.id, exercise.id, pos2)
      Workouts.create_workout_set(we2.id, 1, %{weight: "120.0", reps: 5, is_completed: true})
      {:ok, f2} = Workouts.finish_workout(w2)
      Records.compute_and_save_prs(f2)

      new_best = Records.get_best_records(exercise.id)
      assert Decimal.compare(new_best["max_weight"].value, old_best["max_weight"].value) == :gt
    end

    test "estimated_1rm is computed correctly (Epley: weight * (1 + reps/30))" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)
      # weight=100, reps=10 → 1RM = 100 * (1 + 10/30) = 100 * 1.333... ≈ 133.33
      Workouts.create_workout_set(we.id, 1, %{weight: "100.0", reps: 10, is_completed: true})
      {:ok, finished} = Workouts.finish_workout(workout)
      Records.compute_and_save_prs(finished)

      best = Records.get_best_records(exercise.id)
      assert Map.has_key?(best, "estimated_1rm")

      expected =
        Decimal.mult(
          Decimal.new("100"),
          Decimal.add(Decimal.new(1), Decimal.div(Decimal.new(10), Decimal.new(30)))
        )

      assert Decimal.equal?(best["estimated_1rm"].value, expected)
    end
  end

  describe "list_pr_set_ids_for_workout/1" do
    test "returns set ids that have a PR for the given workout" do
      %{workout: workout, set: set, exercise: _exercise} = completed_workout_fixture()
      # finish_workout already calls compute_and_save_prs
      set_ids = Records.list_pr_set_ids_for_workout(workout.id)
      assert set.id in set_ids
    end

    test "returns empty list when workout has no PRs linked to sets" do
      # Build a completed workout without going through finish_workout so no PRs are computed
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout(%{"name" => "No PR Workout"})
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)
      Workouts.create_workout_set(we.id, 1, %{weight: "50.0", reps: 5, is_completed: true})
      workout = Workouts.get_workout!(workout.id)

      # Mark completed via direct update (bypass finish_workout so compute_and_save_prs is not called)
      Phoenixgym.Workouts.Workout.changeset(workout, %{
        status: "completed",
        finished_at: DateTime.utc_now(),
        duration_seconds: 0,
        total_sets: 1,
        total_reps: 5,
        total_volume: Decimal.new("250")
      })
      |> Repo.update()

      set_ids = Records.list_pr_set_ids_for_workout(workout.id)
      assert set_ids == []
    end

    test "returns only set ids from the given workout" do
      exercise = exercise_fixture()
      {:ok, w1} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(w1.id)
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, pos)

      {:ok, set1} =
        Workouts.create_workout_set(we1.id, 1, %{weight: "100.0", reps: 5, is_completed: true})

      {:ok, finished1} = Workouts.finish_workout(w1)
      Records.compute_and_save_prs(finished1)

      exercise2 = exercise_fixture()
      {:ok, w2} = Workouts.start_workout()
      pos2 = Workouts.next_exercise_position(w2.id)
      {:ok, we2} = Workouts.create_workout_exercise(w2.id, exercise2.id, pos2)
      Workouts.create_workout_set(we2.id, 1, %{weight: "50.0", reps: 10, is_completed: true})
      {:ok, finished2} = Workouts.finish_workout(w2)
      Records.compute_and_save_prs(finished2)

      set_ids_1 = Records.list_pr_set_ids_for_workout(w1.id)
      set_ids_2 = Records.list_pr_set_ids_for_workout(w2.id)

      assert set1.id in set_ids_1
      refute set1.id in set_ids_2
    end
  end
end
