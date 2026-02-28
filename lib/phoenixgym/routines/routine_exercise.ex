defmodule Phoenixgym.Routines.RoutineExercise do
  use Ecto.Schema
  import Ecto.Changeset

  schema "routine_exercises" do
    belongs_to :routine, Phoenixgym.Routines.Routine
    belongs_to :exercise, Phoenixgym.Exercises.Exercise

    field :position, :integer
    field :target_sets, :integer, default: 3

    timestamps(type: :utc_datetime)
  end

  def changeset(routine_exercise, attrs) do
    routine_exercise
    |> cast(attrs, [:routine_id, :exercise_id, :position, :target_sets])
    |> validate_required([:routine_id, :exercise_id, :position])
    |> validate_number(:target_sets, greater_than: 0, less_than_or_equal_to: 20)
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
