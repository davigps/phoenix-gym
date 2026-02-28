defmodule Phoenixgym.Workouts.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workouts" do
    belongs_to :routine, Phoenixgym.Routines.Routine

    field :name, :string
    field :notes, :string
    field :status, :string, default: "in_progress"
    field :started_at, :utc_datetime
    field :finished_at, :utc_datetime
    field :duration_seconds, :integer
    field :total_volume, :decimal
    field :total_sets, :integer
    field :total_reps, :integer

    has_many :workout_exercises, Phoenixgym.Workouts.WorkoutExercise,
      on_delete: :delete_all,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @statuses ~w(in_progress completed discarded)

  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:routine_id, :name, :notes, :status, :started_at, :finished_at,
                    :duration_seconds, :total_volume, :total_sets, :total_reps])
    |> validate_required([:started_at, :status])
    |> validate_inclusion(:status, @statuses)
  end
end
