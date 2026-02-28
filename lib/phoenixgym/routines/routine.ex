defmodule Phoenixgym.Routines.Routine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "routines" do
    field :name, :string
    field :notes, :string

    has_many :routine_exercises, Phoenixgym.Routines.RoutineExercise,
      on_delete: :delete_all,
      on_replace: :delete

    has_many :exercises, through: [:routine_exercises, :exercise]
    has_many :workouts, Phoenixgym.Workouts.Workout

    timestamps(type: :utc_datetime)
  end

  def changeset(routine, attrs) do
    routine
    |> cast(attrs, [:name, :notes])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
  end
end
