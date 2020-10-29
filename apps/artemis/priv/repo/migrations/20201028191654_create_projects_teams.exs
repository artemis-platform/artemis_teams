defmodule Artemis.Repo.Migrations.CreateProjectsTeams do
  use Ecto.Migration

  def change do
    create table(:projects_teams, primary_key: false) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
    end
  end
end
