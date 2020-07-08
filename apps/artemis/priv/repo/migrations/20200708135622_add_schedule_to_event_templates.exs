defmodule Artemis.Repo.Migrations.AddScheduleToEventTemplates do
  use Ecto.Migration

  def change do
    alter table(:event_templates) do
      add :schedule, :text
    end
  end
end
