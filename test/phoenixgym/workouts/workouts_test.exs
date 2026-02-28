defmodule Phoenixgym.WorkoutsTest do
  use Phoenixgym.DataCase, async: true

  alias Phoenixgym.Workouts
  alias Phoenixgym.Workouts.{Workout, WorkoutExercise, WorkoutSet}
  alias Phoenixgym.Routines
  import Phoenixgym.Fixtures

  # ── Changeset tests ──────────────────────────────────────────────────────

  describe "Workout.changeset/2" do
    @valid_workout_attrs %{
      started_at: ~U[2024-01-01 10:00:00Z],
      status: "in_progress"
    }

    test "valid attrs produce a valid changeset" do
      assert Workout.changeset(%Workout{}, @valid_workout_attrs).valid?
    end

    test "started_at is required" do
      errors = errors_on(Workout.changeset(%Workout{}, %{status: "in_progress"}))
      assert errors[:started_at] != nil
    end

    test "status defaults to in_progress when not provided" do
      cs = Workout.changeset(%Workout{}, %{started_at: DateTime.utc_now()})
      assert cs.valid?
      assert Ecto.Changeset.get_field(cs, :status) == "in_progress"
    end

    test "invalid status is rejected" do
      errors =
        errors_on(Workout.changeset(%Workout{}, Map.put(@valid_workout_attrs, :status, "paused")))

      assert errors[:status] != nil
    end

    test "all valid statuses are accepted" do
      for status <- ~w(in_progress completed discarded) do
        cs = Workout.changeset(%Workout{}, Map.put(@valid_workout_attrs, :status, status))
        assert cs.valid?, "expected status #{status} to be valid"
      end
    end
  end

  describe "WorkoutSet.changeset/2" do
    @valid_set_attrs %{
      workout_exercise_id: 1,
      set_number: 1,
      set_type: "normal",
      weight: "60.0",
      reps: 10
    }

    test "valid attrs produce a valid changeset" do
      assert WorkoutSet.changeset(%WorkoutSet{}, @valid_set_attrs).valid?
    end

    test "workout_exercise_id and set_number are required" do
      errors = errors_on(WorkoutSet.changeset(%WorkoutSet{}, %{}))
      assert errors[:workout_exercise_id] != nil
      assert errors[:set_number] != nil
    end

    test "invalid set_type is rejected" do
      errors =
        errors_on(
          WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :set_type, "superset"))
        )

      assert errors[:set_type] != nil
    end

    test "all valid set_types are accepted" do
      for type <- WorkoutSet.set_types() do
        cs = WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :set_type, type))
        assert cs.valid?, "expected set_type #{type} to be valid"
      end
    end

    test "weight cannot be negative" do
      errors =
        errors_on(WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :weight, "-1")))

      assert errors[:weight] != nil
    end

    test "weight of 0 is valid (bodyweight exercises)" do
      assert WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :weight, "0")).valid?
    end

    test "rpe must be between 1 and 10" do
      errors_low =
        errors_on(WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :rpe, "0")))

      assert errors_low[:rpe] != nil

      errors_high =
        errors_on(WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :rpe, "11")))

      assert errors_high[:rpe] != nil
    end

    test "rpe of 1 and 10 are valid" do
      for rpe <- ["1", "10"] do
        cs = WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :rpe, rpe))
        assert cs.valid?, "expected RPE #{rpe} to be valid"
      end
    end

    test "set_number must be positive" do
      errors =
        errors_on(WorkoutSet.changeset(%WorkoutSet{}, Map.put(@valid_set_attrs, :set_number, 0)))

      assert errors[:set_number] != nil
    end
  end

  # ── Context CRUD tests ───────────────────────────────────────────────────

  describe "Workouts context — workout lifecycle" do
    test "start_workout/0 creates an in_progress workout" do
      assert {:ok, workout} = Workouts.start_workout()
      assert workout.status == "in_progress"
      assert workout.started_at != nil
    end

    test "start_workout/1 accepts a custom name" do
      assert {:ok, workout} = Workouts.start_workout(%{"name" => "Morning Session"})
      assert workout.name == "Morning Session"
    end

    test "get_workout!/1 returns workout with associations preloaded" do
      workout = workout_fixture()
      fetched = Workouts.get_workout!(workout.id)
      assert fetched.id == workout.id
      assert fetched.workout_exercises == []
    end

    test "get_workout!/1 raises for unknown id" do
      assert_raise Ecto.NoResultsError, fn -> Workouts.get_workout!(0) end
    end

    test "get_in_progress_workout/0 returns the current in-progress workout" do
      {:ok, workout} = Workouts.start_workout()
      found = Workouts.get_in_progress_workout()
      assert found.id == workout.id
    end

    test "get_in_progress_workout/0 returns nil when none exists" do
      assert Workouts.get_in_progress_workout() == nil
    end

    test "finish_workout/1 sets status to completed and computes totals" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)

      Workouts.create_workout_set(we.id, 1, %{
        weight: "100.0",
        reps: 5,
        set_type: "normal",
        is_completed: true
      })

      Workouts.create_workout_set(we.id, 2, %{
        weight: "80.0",
        reps: 8,
        set_type: "normal",
        is_completed: true
      })

      assert {:ok, finished} = Workouts.finish_workout(workout)
      assert finished.status == "completed"
      assert finished.finished_at != nil
      assert finished.duration_seconds >= 0
      assert finished.total_sets == 2
      assert finished.total_reps == 13
      # volume = 100*5 + 80*8 = 500 + 640 = 1140
      assert Decimal.equal?(finished.total_volume, Decimal.new("1140"))
    end

    test "finish_workout/1 excludes incomplete sets from totals" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)

      Workouts.create_workout_set(we.id, 1, %{
        weight: "100.0",
        reps: 5,
        set_type: "normal",
        is_completed: true
      })

      Workouts.create_workout_set(we.id, 2, %{
        weight: "100.0",
        reps: 5,
        set_type: "normal",
        is_completed: false
      })

      {:ok, finished} = Workouts.finish_workout(workout)
      assert finished.total_sets == 1
      assert finished.total_reps == 5
    end

    test "discard_workout/1 sets status to discarded" do
      {:ok, workout} = Workouts.start_workout()
      assert {:ok, discarded} = Workouts.discard_workout(workout)
      assert discarded.status == "discarded"
    end

    test "delete_workout/1 removes the workout" do
      {:ok, workout} = Workouts.start_workout()
      assert {:ok, _} = Workouts.delete_workout(workout)
      assert_raise Ecto.NoResultsError, fn -> Workouts.get_workout!(workout.id) end
    end

    test "list_workouts/0 returns only completed workouts by default" do
      %{workout: completed} = completed_workout_fixture()
      {:ok, in_progress} = Workouts.start_workout()

      completed_ids = Workouts.list_workouts() |> Enum.map(& &1.id)
      assert completed.id in completed_ids
      refute in_progress.id in completed_ids
    end
  end

  describe "list_completed_workouts/1" do
    test "returns only status completed workouts ordered by finished_at descending" do
      %{workout: w1} = completed_workout_fixture()
      %{workout: w2} = completed_workout_fixture()
      {:ok, _in_progress} = Workouts.start_workout()
      {:ok, discarded} = Workouts.start_workout()
      Workouts.discard_workout(discarded)

      list = Workouts.list_completed_workouts()
      ids = Enum.map(list, & &1.id)
      assert w1.id in ids
      assert w2.id in ids
      refute discarded.id in ids
      assert list == Enum.sort_by(list, & &1.finished_at, {:desc, DateTime})
    end

    test "respects limit option" do
      completed_workout_fixture()
      completed_workout_fixture()
      completed_workout_fixture()

      list = Workouts.list_completed_workouts(limit: 2)
      assert length(list) == 2
    end

    test "respects offset option" do
      %{workout: first} = completed_workout_fixture()
      completed_workout_fixture()
      completed_workout_fixture()

      list = Workouts.list_completed_workouts(limit: 1, offset: 1)
      assert length(list) == 1
      refute hd(list).id == first.id
    end

    test "default limit is 20" do
      for _ <- 1..25, do: completed_workout_fixture()
      list = Workouts.list_completed_workouts()
      assert length(list) == 20
    end
  end

  describe "Workouts context — exercises and sets" do
    test "create_workout_exercise/3 adds an exercise to a workout" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()

      assert {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, 0)
      assert we.workout_id == workout.id
      assert we.exercise_id == exercise.id
      assert we.position == 0
    end

    test "next_exercise_position/1 increments with each added exercise" do
      exercise1 = exercise_fixture()
      exercise2 = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()

      pos1 = Workouts.next_exercise_position(workout.id)
      Workouts.create_workout_exercise(workout.id, exercise1.id, pos1)

      pos2 = Workouts.next_exercise_position(workout.id)
      Workouts.create_workout_exercise(workout.id, exercise2.id, pos2)

      assert pos2 > pos1
    end

    test "create_workout_set/3 adds a set to a workout exercise" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, 0)

      assert {:ok, set} = Workouts.create_workout_set(we.id, 1)
      assert set.workout_exercise_id == we.id
      assert set.set_number == 1
      assert set.is_completed == false
    end

    test "update_workout_set/2 updates weight, reps, and RPE" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, 0)
      {:ok, set} = Workouts.create_workout_set(we.id, 1)

      assert {:ok, updated} =
               Workouts.update_workout_set(set, %{weight: "75.5", reps: 8, rpe: "8.5"})

      assert Decimal.equal?(updated.weight, Decimal.new("75.5"))
      assert updated.reps == 8
      assert Decimal.equal?(updated.rpe, Decimal.new("8.5"))
    end

    test "delete_workout_exercise/1 removes the exercise" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, 0)

      assert {:ok, _} = Workouts.delete_workout_exercise(we)
      assert Repo.get(WorkoutExercise, we.id) == nil
    end

    test "delete_workout_set/1 removes the set" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, 0)
      {:ok, set} = Workouts.create_workout_set(we.id, 1)

      assert {:ok, _} = Workouts.delete_workout_set(set)
      assert Repo.get(WorkoutSet, set.id) == nil
    end
  end

  describe "Workouts context — start_workout_from_routine/1" do
    test "pre-populates exercises and target sets from routine" do
      routine = routine_fixture()
      ex1 = exercise_fixture()
      ex2 = exercise_fixture()
      {:ok, re1} = Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.update_routine_exercise(re1, %{target_sets: 3})
      {:ok, re2} = Routines.add_exercise_to_routine(routine.id, ex2.id)
      Routines.update_routine_exercise(re2, %{target_sets: 2})

      routine = Routines.get_routine!(routine.id)
      assert {:ok, workout} = Workouts.start_workout_from_routine(routine)

      assert workout.routine_id == routine.id
      assert length(workout.workout_exercises) == 2

      total_sets =
        workout.workout_exercises
        |> Enum.flat_map(& &1.workout_sets)
        |> length()

      assert total_sets == 5
    end
  end

  describe "Workouts context — get_previous_sets/2" do
    test "returns sets from the last completed workout for an exercise" do
      exercise = exercise_fixture()

      # First completed workout
      {:ok, w1} = Workouts.start_workout()
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, 0)
      Workouts.create_workout_set(we1.id, 1, %{weight: "60.0", reps: 10, is_completed: true})
      Workouts.finish_workout(w1)

      # Current in-progress workout
      {:ok, w2} = Workouts.start_workout()

      prev = Workouts.get_previous_sets(exercise.id, w2.id)
      assert length(prev) == 1
      assert Decimal.equal?(hd(prev).weight, Decimal.new("60.0"))
    end

    test "excludes sets from the current workout" do
      exercise = exercise_fixture()
      {:ok, w1} = Workouts.start_workout()
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, 0)
      Workouts.create_workout_set(we1.id, 1, %{weight: "60.0", reps: 10, is_completed: true})

      prev = Workouts.get_previous_sets(exercise.id, w1.id)
      assert prev == []
    end

    test "returns empty list when no prior completed workout" do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout()
      prev = Workouts.get_previous_sets(exercise.id, workout.id)
      assert prev == []
    end

    test "excludes incomplete sets" do
      exercise = exercise_fixture()
      {:ok, w1} = Workouts.start_workout()
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, 0)
      Workouts.create_workout_set(we1.id, 1, %{weight: "60.0", reps: 10, is_completed: false})
      Workouts.finish_workout(w1)

      {:ok, w2} = Workouts.start_workout()
      prev = Workouts.get_previous_sets(exercise.id, w2.id)
      assert prev == []
    end
  end
end
