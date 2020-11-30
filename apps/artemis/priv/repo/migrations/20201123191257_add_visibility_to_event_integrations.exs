defmodule Artemis.Repo.Migrations.AddVisibilityToEventIntegrations do
  use Ecto.Migration

  def change do
    alter table(:event_integrations) do
      add :visibility, :string
    end

    create index(:event_integrations, [:visibility])
  end
end
