defmodule Artemis.Repo.Migrations.CreateStandups do
  use Ecto.Migration

  def change do
    create table(:standups) do
      add :date, :date
      add :past, :string
      add :future, :string
      add :blockers, :string
      add :team_id, references(:teams, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps(type: :utc_datetime)
    end

    create index(:standups, [:date])
    create unique_index(:standups, [:date, :team_id, :user_id])
  end
end
