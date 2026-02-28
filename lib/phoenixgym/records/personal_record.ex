defmodule Phoenixgym.Records.PersonalRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "personal_records" do
    belongs_to :exercise, Phoenixgym.Exercises.Exercise
    belongs_to :workout_set, Phoenixgym.Workouts.WorkoutSet

    field :record_type, :string
    field :value, :decimal
    field :achieved_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @record_types ~w(max_weight max_reps estimated_1rm max_volume_set max_volume_session)

  def changeset(personal_record, attrs) do
    personal_record
    |> cast(attrs, [:exercise_id, :workout_set_id, :record_type, :value, :achieved_at])
    |> validate_required([:exercise_id, :record_type, :value, :achieved_at])
    |> validate_inclusion(:record_type, @record_types)
    |> validate_number(:value, greater_than: 0)
  end

  def record_types, do: @record_types
end
