defmodule Phoenixgym.Repo.Migrations.CreateWorkouts do
  use Ecto.Migration

  def change do
    create table(:workouts) do
      add :routine_id, references(:routines, on_delete: :nilify_all)
      add :name, :string
      add :notes, :text
      add :status, :string, default: "in_progress", null: false
      add :started_at, :utc_datetime, null: false
      add :finished_at, :utc_datetime
      add :duration_seconds, :integer
      add :total_volume, :decimal
      add :total_sets, :integer
      add :total_reps, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:workouts, [:status])
    create index(:workouts, [:routine_id])
    create index(:workouts, [:started_at])
  end
end
