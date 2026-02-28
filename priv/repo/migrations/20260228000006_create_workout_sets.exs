defmodule Phoenixgym.Repo.Migrations.CreateWorkoutSets do
  use Ecto.Migration

  def change do
    create table(:workout_sets) do
      add :workout_exercise_id, references(:workout_exercises, on_delete: :delete_all),
        null: false

      add :set_number, :integer, null: false
      add :set_type, :string, default: "normal", null: false
      add :weight, :decimal
      add :reps, :integer
      add :rpe, :decimal
      add :is_completed, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:workout_sets, [:workout_exercise_id, :set_number])
  end
end
