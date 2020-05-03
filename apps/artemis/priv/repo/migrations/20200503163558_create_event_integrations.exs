defmodule Artemis.Repo.Migrations.CreateEventIntegrations do
  use Ecto.Migration

  def change do
    create table(:event_integrations) do
      add :active, :boolean
      add :integration_type, :string
      add :name, :string
      add :notification_type, :string
      add :settings, :map

      add :event_template_id, references(:event_templates, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:event_integrations, [:active])
    create index(:event_integrations, [:integration_type])
    create index(:event_integrations, [:notification_type])
    create index(:event_integrations, [:event_template_id, :integration_type])
    create index(:event_integrations, [:event_template_id, :notification_type])
  end
end
