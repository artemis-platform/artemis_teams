defmodule Artemis.Repo.Migrations.CreateEventTemplates do
  use Ecto.Migration

  def change do
    create table(:event_templates) do
      add :active, :boolean
      add :name, :string
      add :slug, :string
      add :type, :string
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:event_templates, [:active])
    create index(:event_templates, [:type])
    create unique_index(:event_templates, [:team_id, :slug], name: :event_templates_team_id_slug_index)
  end
end
