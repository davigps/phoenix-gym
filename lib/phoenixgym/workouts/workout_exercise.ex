defmodule Phoenixgym.Workouts.WorkoutExercise do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workout_exercises" do
    belongs_to :workout, Phoenixgym.Workouts.Workout
    belongs_to :exercise, Phoenixgym.Exercises.Exercise

    field :position, :integer
    field :notes, :string

    has_many :workout_sets, Phoenixgym.Workouts.WorkoutSet,
      on_delete: :delete_all,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(workout_exercise, attrs) do
    workout_exercise
    |> cast(attrs, [:workout_id, :exercise_id, :position, :notes])
    |> validate_required([:workout_id, :exercise_id, :position])
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
