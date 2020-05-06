defmodule Artemis.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :active, :boolean
      add :description, :text
      add :description_html, :text
      add :title, :string

      add :team_id, references(:teams, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:title])
  end
end
