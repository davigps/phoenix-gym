defmodule Phoenixgym.Repo.Migrations.AddCodeToExercises do
  use Ecto.Migration

  def change do
    alter table(:exercises) do
      add :code, :string
    end

    create unique_index(:exercises, [:code])
  end
end
