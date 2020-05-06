defmodule Artemis.Repo.Migrations.RemoveCategoriesFromEventTemplates do
  use Ecto.Migration

  def change do
    alter table(:event_templates) do
      remove :categories
    end
  end
end
