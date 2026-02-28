defmodule Phoenixgym.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises) do
      add :name, :string, null: false
      add :category, :string
      add :primary_muscle, :string
      add :secondary_muscles, {:array, :string}, default: []
      add :equipment, :string
      add :instructions, :text
      add :is_custom, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:exercises, [:primary_muscle])
    create index(:exercises, [:category])
    create index(:exercises, [:equipment])
    create unique_index(:exercises, [:name])
  end
end
