defmodule Artemis.Repo.Migrations.AddScheduleToEventIntegrations do
  use Ecto.Migration

  def change do
    alter table(:event_integrations) do
      add :schedule, :text
    end
  end
end
