defmodule Phoenixgym.Workouts.WorkoutSet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workout_sets" do
    belongs_to :workout_exercise, Phoenixgym.Workouts.WorkoutExercise

    field :set_number, :integer
    field :set_type, :string, default: "normal"
    field :weight, :decimal
    field :reps, :integer
    field :rpe, :decimal
    field :is_completed, :boolean, default: false

    has_many :personal_records, Phoenixgym.Records.PersonalRecord

    timestamps(type: :utc_datetime)
  end

  @set_types ~w(warmup normal drop)

  def changeset(workout_set, attrs) do
    workout_set
    |> cast(attrs, [:workout_exercise_id, :set_number, :set_type, :weight, :reps, :rpe, :is_completed])
    |> validate_required([:workout_exercise_id, :set_number])
    |> validate_inclusion(:set_type, @set_types)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:reps, greater_than_or_equal_to: 0)
    |> validate_number(:rpe, greater_than_or_equal_to: 1, less_than_or_equal_to: 10)
    |> validate_number(:set_number, greater_than: 0)
  end

  def set_types, do: @set_types
end
