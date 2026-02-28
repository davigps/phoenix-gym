defmodule Phoenixgym.Repo.Migrations.CreateWorkoutExercises do
  use Ecto.Migration

  def change do
    create table(:workout_exercises) do
      add :workout_id, references(:workouts, on_delete: :delete_all), null: false
      add :exercise_id, references(:exercises, on_delete: :restrict), null: false
      add :position, :integer, null: false
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:workout_exercises, [:workout_id, :position])
    create index(:workout_exercises, [:exercise_id])
  end
end
