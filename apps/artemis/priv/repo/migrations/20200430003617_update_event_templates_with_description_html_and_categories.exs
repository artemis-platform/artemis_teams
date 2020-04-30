defmodule Artemis.Repo.Migrations.UpdateEventTemplatesWithDescriptionHtmlAndCategories do
  use Ecto.Migration

  def change do
    alter table(:event_templates) do
      add :description_html, :text
      add :categories, :map
    end
  end
end
