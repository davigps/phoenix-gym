defmodule Phoenixgym.ExercisesTest do
  use Phoenixgym.DataCase, async: true

  alias Phoenixgym.Exercises
  alias Phoenixgym.Exercises.Exercise
  import Phoenixgym.Fixtures

  @valid_attrs %{
    "name" => "Bench Press",
    "category" => "strength",
    "primary_muscle" => "chest",
    "equipment" => "barbell"
  }

  # ── Changeset tests ──────────────────────────────────────────────────────

  describe "Exercise.changeset/2" do
    test "valid attrs produce a valid changeset" do
      assert Exercise.changeset(%Exercise{}, @valid_attrs).valid?
    end

    test "name is required" do
      errors = errors_on(Exercise.changeset(%Exercise{}, Map.delete(@valid_attrs, "name")))
      assert errors[:name] != nil
    end

    test "invalid category is rejected" do
      errors =
        errors_on(Exercise.changeset(%Exercise{}, Map.put(@valid_attrs, "category", "crossfit")))

      assert errors[:category] != nil
      assert hd(errors[:category]) =~ "must be one of"
    end

    test "invalid primary_muscle is rejected" do
      errors =
        errors_on(Exercise.changeset(%Exercise{}, Map.put(@valid_attrs, "primary_muscle", "toe")))

      assert errors[:primary_muscle] != nil
    end

    test "invalid equipment is rejected" do
      errors =
        errors_on(Exercise.changeset(%Exercise{}, Map.put(@valid_attrs, "equipment", "stick")))

      assert errors[:equipment] != nil
    end

    test "all valid categories are accepted" do
      for cat <- Exercise.categories() do
        cs = Exercise.changeset(%Exercise{}, Map.put(@valid_attrs, "category", cat))
        assert cs.valid?, "expected category #{cat} to be valid"
      end
    end

    test "all valid muscle groups are accepted" do
      for muscle <- Exercise.muscles() do
        cs = Exercise.changeset(%Exercise{}, Map.put(@valid_attrs, "primary_muscle", muscle))
        assert cs.valid?, "expected muscle #{muscle} to be valid"
      end
    end

    test "all valid equipment types are accepted" do
      for eq <- Exercise.equipment_types() do
        cs = Exercise.changeset(%Exercise{}, Map.put(@valid_attrs, "equipment", eq))
        assert cs.valid?, "expected equipment #{eq} to be valid"
      end
    end

    test "secondary_muscles defaults to empty list" do
      {:ok, ex} = Exercises.create_exercise(@valid_attrs)
      assert ex.secondary_muscles == []
    end
  end

  # ── Context CRUD tests ───────────────────────────────────────────────────

  describe "Exercises context" do
    test "create_exercise/1 inserts and marks is_custom true" do
      assert {:ok, ex} = Exercises.create_exercise(@valid_attrs)
      assert ex.name == "Bench Press"
      assert ex.is_custom == true
    end

    test "create_exercise/1 returns error changeset for missing name" do
      assert {:error, cs} = Exercises.create_exercise(%{"category" => "strength"})
      assert errors_on(cs)[:name] != nil
    end

    test "create_exercise/1 enforces unique name" do
      assert {:ok, _} = Exercises.create_exercise(@valid_attrs)
      assert {:error, cs} = Exercises.create_exercise(@valid_attrs)
      assert errors_on(cs)[:name] != nil
    end

    test "get_exercise!/1 returns the exercise" do
      {:ok, ex} = Exercises.create_exercise(@valid_attrs)
      fetched = Exercises.get_exercise!(ex.id)
      assert fetched.id == ex.id
      assert fetched.name == "Bench Press"
    end

    test "get_exercise!/1 raises for unknown id" do
      assert_raise Ecto.NoResultsError, fn -> Exercises.get_exercise!(0) end
    end

    test "update_exercise/2 changes fields" do
      {:ok, ex} = Exercises.create_exercise(@valid_attrs)
      assert {:ok, updated} = Exercises.update_exercise(ex, %{"name" => "Updated Press"})
      assert updated.name == "Updated Press"
    end

    test "update_exercise/2 rejects invalid category" do
      {:ok, ex} = Exercises.create_exercise(@valid_attrs)
      assert {:error, cs} = Exercises.update_exercise(ex, %{"category" => "bad"})
      assert errors_on(cs)[:category] != nil
    end

    test "delete_exercise/1 removes the exercise" do
      {:ok, ex} = Exercises.create_exercise(@valid_attrs)
      assert {:ok, _} = Exercises.delete_exercise(ex)
      assert_raise Ecto.NoResultsError, fn -> Exercises.get_exercise!(ex.id) end
    end

    test "list_exercises/0 returns all exercises" do
      ex = exercise_fixture()
      ids = Exercises.list_exercises() |> Enum.map(& &1.id)
      assert ex.id in ids
    end

    test "list_exercises/1 empty search returns all" do
      exercise_fixture()
      all = Exercises.list_exercises()
      blank = Exercises.list_exercises(search: "")
      assert length(all) == length(blank)
    end

    test "list_exercises/1 search filters by name (case-insensitive)" do
      unique = "ZZZUniquePressName#{System.unique_integer([:positive])}"
      {:ok, _} = Exercises.create_exercise(Map.put(@valid_attrs, "name", unique))
      results = Exercises.list_exercises(search: "ZZZUnique")
      assert Enum.any?(results, &(&1.name == unique))
      assert Enum.all?(results, &String.contains?(String.downcase(&1.name), "zzzunique"))
    end

    test "list_exercises/1 filters by primary_muscle" do
      {:ok, _} =
        Exercises.create_exercise(
          Map.put(@valid_attrs, "name", "Chest Ex#{System.unique_integer()}")
        )

      {:ok, _} =
        Exercises.create_exercise(%{
          "name" => "Leg Ex#{System.unique_integer()}",
          "category" => "strength",
          "primary_muscle" => "legs",
          "equipment" => "barbell"
        })

      results = Exercises.list_exercises(primary_muscle: "chest")
      assert Enum.all?(results, &(&1.primary_muscle == "chest"))
    end

    test "list_exercises/1 filters by equipment" do
      {:ok, _} =
        Exercises.create_exercise(
          Map.put(@valid_attrs, "name", "KB Ex#{System.unique_integer()}")
          |> Map.put("equipment", "kettlebell")
        )

      results = Exercises.list_exercises(equipment: "kettlebell")
      assert Enum.all?(results, &(&1.equipment == "kettlebell"))
    end

    test "list_exercises/1 filters by category" do
      {:ok, _} =
        Exercises.create_exercise(%{
          "name" => "Cardio Ex#{System.unique_integer()}",
          "category" => "cardio",
          "primary_muscle" => "cardio",
          "equipment" => "machine"
        })

      results = Exercises.list_exercises(category: "cardio")
      assert Enum.all?(results, &(&1.category == "cardio"))
    end
  end

  # ── Seeds idempotency ────────────────────────────────────────────────────

  describe "seeds idempotency" do
    test "inserting the same exercises twice skips duplicates without errors" do
      seed_exercises = [
        %{
          name: "Seed Idem Test Squat",
          category: "strength",
          primary_muscle: "legs",
          equipment: "barbell"
        },
        %{
          name: "Seed Idem Test Pull-Up",
          category: "strength",
          primary_muscle: "back",
          equipment: "bodyweight"
        }
      ]

      run_seed = fn ->
        Enum.each(seed_exercises, fn attrs ->
          case Repo.get_by(Exercise, name: attrs.name) do
            nil ->
              Repo.insert!(%Exercise{
                name: attrs.name,
                category: attrs.category,
                primary_muscle: attrs.primary_muscle,
                equipment: attrs.equipment,
                secondary_muscles: [],
                is_custom: false
              })

            _existing ->
              :skip
          end
        end)
      end

      # First run: both exercises inserted
      run_seed.()
      count_after_first = Repo.aggregate(Exercise, :count, :id)
      assert count_after_first == length(seed_exercises)

      # Second run: no new rows, no errors
      run_seed.()
      count_after_second = Repo.aggregate(Exercise, :count, :id)
      assert count_after_second == count_after_first
    end
  end
end
