defmodule Phoenixgym.RoutinesTest do
  use Phoenixgym.DataCase, async: true

  alias Phoenixgym.Routines
  alias Phoenixgym.Routines.{Routine, RoutineExercise}
  import Phoenixgym.Fixtures

  @valid_attrs %{"name" => "Push Day A"}

  # ── Changeset tests ──────────────────────────────────────────────────────

  describe "Routine.changeset/2" do
    test "valid attrs produce a valid changeset" do
      assert Routine.changeset(%Routine{}, @valid_attrs).valid?
    end

    test "name is required" do
      errors = errors_on(Routine.changeset(%Routine{}, %{}))
      assert errors[:name] != nil
    end

    test "name cannot exceed 100 characters" do
      long_name = String.duplicate("a", 101)
      errors = errors_on(Routine.changeset(%Routine{}, %{"name" => long_name}))
      assert errors[:name] != nil
    end

    test "name at exactly 100 characters is valid" do
      name = String.duplicate("a", 100)
      assert Routine.changeset(%Routine{}, %{"name" => name}).valid?
    end

    test "notes are optional" do
      assert Routine.changeset(%Routine{}, @valid_attrs).valid?
      assert Routine.changeset(%Routine{}, Map.put(@valid_attrs, "notes", "some notes")).valid?
    end
  end

  describe "RoutineExercise.changeset/2" do
    test "valid attrs produce a valid changeset" do
      attrs = %{routine_id: 1, exercise_id: 1, position: 0, target_sets: 3}
      assert RoutineExercise.changeset(%RoutineExercise{}, attrs).valid?
    end

    test "routine_id, exercise_id, and position are required" do
      errors = errors_on(RoutineExercise.changeset(%RoutineExercise{}, %{}))
      assert errors[:routine_id] != nil
      assert errors[:exercise_id] != nil
      assert errors[:position] != nil
    end

    test "target_sets must be greater than 0" do
      attrs = %{routine_id: 1, exercise_id: 1, position: 0, target_sets: 0}
      errors = errors_on(RoutineExercise.changeset(%RoutineExercise{}, attrs))
      assert errors[:target_sets] != nil
    end

    test "target_sets cannot exceed 20" do
      attrs = %{routine_id: 1, exercise_id: 1, position: 0, target_sets: 21}
      errors = errors_on(RoutineExercise.changeset(%RoutineExercise{}, attrs))
      assert errors[:target_sets] != nil
    end

    test "position must be >= 0" do
      attrs = %{routine_id: 1, exercise_id: 1, position: -1}
      errors = errors_on(RoutineExercise.changeset(%RoutineExercise{}, attrs))
      assert errors[:position] != nil
    end
  end

  # ── Context CRUD tests ───────────────────────────────────────────────────

  describe "Routines context" do
    test "create_routine/1 inserts a routine" do
      assert {:ok, routine} = Routines.create_routine(@valid_attrs)
      assert routine.name == "Push Day A"
    end

    test "create_routine/1 fails without a name" do
      assert {:error, cs} = Routines.create_routine(%{})
      assert errors_on(cs)[:name] != nil
    end

    test "get_routine!/1 returns the routine with exercises preloaded" do
      routine = routine_fixture()
      fetched = Routines.get_routine!(routine.id)
      assert fetched.id == routine.id
      assert fetched.routine_exercises == []
    end

    test "get_routine!/1 raises for unknown id" do
      assert_raise Ecto.NoResultsError, fn -> Routines.get_routine!(0) end
    end

    test "update_routine/2 changes name" do
      routine = routine_fixture()
      assert {:ok, updated} = Routines.update_routine(routine, %{"name" => "Leg Day"})
      assert updated.name == "Leg Day"
    end

    test "delete_routine/1 removes the routine" do
      routine = routine_fixture()
      assert {:ok, _} = Routines.delete_routine(routine)
      assert_raise Ecto.NoResultsError, fn -> Routines.get_routine!(routine.id) end
    end

    test "list_routines/0 returns all routines" do
      routine = routine_fixture()
      ids = Routines.list_routines() |> Enum.map(& &1.id)
      assert routine.id in ids
    end

    test "add_exercise_to_routine/2 adds exercise at next position" do
      routine = routine_fixture()
      exercise = exercise_fixture()

      assert {:ok, re} = Routines.add_exercise_to_routine(routine.id, exercise.id)
      assert re.routine_id == routine.id
      assert re.exercise_id == exercise.id
      assert re.position == 0
    end

    test "add_exercise_to_routine/2 increments position for each exercise" do
      routine = routine_fixture()
      ex1 = exercise_fixture()
      ex2 = exercise_fixture()

      {:ok, re1} = Routines.add_exercise_to_routine(routine.id, ex1.id)
      {:ok, re2} = Routines.add_exercise_to_routine(routine.id, ex2.id)

      assert re2.position == re1.position + 1
    end

    test "delete_routine/1 cascades to routine_exercises" do
      routine = routine_fixture()
      exercise = exercise_fixture()
      {:ok, re} = Routines.add_exercise_to_routine(routine.id, exercise.id)

      Routines.delete_routine(routine)

      refute Repo.get(RoutineExercise, re.id)
    end

    test "duplicate_routine/1 copies routine with exercises and correct positions" do
      routine = routine_fixture()
      ex1 = exercise_fixture()
      ex2 = exercise_fixture()
      Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.add_exercise_to_routine(routine.id, ex2.id)

      assert {:ok, copy} = Routines.duplicate_routine(routine)

      assert copy.name == "#{routine.name} (Cópia)"
      copy = Routines.get_routine!(copy.id)
      assert length(copy.routine_exercises) == 2

      positions = Enum.map(copy.routine_exercises, & &1.position) |> Enum.sort()
      assert positions == [0, 1]
    end

    test "move_exercise/3 swaps positions when moving down" do
      routine = routine_fixture()
      ex1 = exercise_fixture()
      ex2 = exercise_fixture()
      {:ok, re1} = Routines.add_exercise_to_routine(routine.id, ex1.id)
      {:ok, re2} = Routines.add_exercise_to_routine(routine.id, ex2.id)

      assert {:ok, _} = Routines.move_exercise(routine.id, ex1.id, :down)

      updated_re1 = Repo.get!(RoutineExercise, re1.id)
      updated_re2 = Repo.get!(RoutineExercise, re2.id)

      assert updated_re1.position == re2.position
      assert updated_re2.position == re1.position
    end

    test "move_exercise/3 returns :noop at boundary" do
      routine = routine_fixture()
      exercise = exercise_fixture()
      Routines.add_exercise_to_routine(routine.id, exercise.id)

      assert {:ok, :noop} = Routines.move_exercise(routine.id, exercise.id, :up)
    end
  end
end
