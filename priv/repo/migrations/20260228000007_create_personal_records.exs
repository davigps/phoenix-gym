defmodule Phoenixgym.Repo.Migrations.CreatePersonalRecords do
  use Ecto.Migration

  def change do
    create table(:personal_records) do
      add :exercise_id, references(:exercises, on_delete: :delete_all), null: false
      add :workout_set_id, references(:workout_sets, on_delete: :nilify_all)
      add :record_type, :string, null: false
      add :value, :decimal, null: false
      add :achieved_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:personal_records, [:exercise_id, :record_type])
    create index(:personal_records, [:workout_set_id])
  end
end
