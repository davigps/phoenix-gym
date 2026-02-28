defmodule Phoenixgym.Repo.Migrations.CreateRoutineExercises do
  use Ecto.Migration

  def change do
    create table(:routine_exercises) do
      add :routine_id, references(:routines, on_delete: :delete_all), null: false
      add :exercise_id, references(:exercises, on_delete: :restrict), null: false
      add :position, :integer, null: false
      add :target_sets, :integer, default: 3

      timestamps(type: :utc_datetime)
    end

    create index(:routine_exercises, [:routine_id, :position])
    create index(:routine_exercises, [:exercise_id])
  end
end
