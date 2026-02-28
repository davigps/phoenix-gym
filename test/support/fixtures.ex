defmodule Phoenixgym.Fixtures do
  alias Phoenixgym.{Exercises, Routines, Workouts}

  def exercise_fixture(attrs \\ %{}) do
    {:ok, exercise} =
      attrs
      |> Enum.into(%{
        "name" => "Test Exercise #{System.unique_integer([:positive])}",
        "category" => "strength",
        "primary_muscle" => "chest",
        "equipment" => "barbell"
      })
      |> Exercises.create_exercise()

    exercise
  end

  def routine_fixture(attrs \\ %{}) do
    {:ok, routine} =
      attrs
      |> Enum.into(%{"name" => "Test Routine #{System.unique_integer([:positive])}"})
      |> Routines.create_routine()

    routine
  end

  def workout_fixture(attrs \\ %{}) do
    {:ok, workout} = Workouts.start_workout(attrs)
    workout
  end

  def completed_workout_fixture do
    exercise = exercise_fixture()
    {:ok, workout} = Workouts.start_workout(%{"name" => "Test Workout"})
    pos = Workouts.next_exercise_position(workout.id)
    {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)

    {:ok, set} =
      Workouts.create_workout_set(we.id, 1, %{
        weight: Decimal.new("100.0"),
        reps: 5,
        set_type: "normal",
        is_completed: true
      })

    {:ok, completed_workout} = Workouts.finish_workout(workout)
    %{workout: completed_workout, workout_exercise: we, set: set, exercise: exercise}
  end
end
