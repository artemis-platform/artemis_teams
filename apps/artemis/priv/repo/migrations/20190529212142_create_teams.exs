defmodule Artemis.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :active, :boolean
      add :description, :text
      add :name, :string
      add :slug, :string
      timestamps(type: :utc_datetime)
    end

    create index(:teams, [:active])
    create unique_index(:teams, [:slug])
  end
end
