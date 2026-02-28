defmodule Phoenixgym.Repo.Migrations.CreateRoutines do
  use Ecto.Migration

  def change do
    create table(:routines) do
      add :name, :string, null: false
      add :notes, :text

      timestamps(type: :utc_datetime)
    end
  end
end
