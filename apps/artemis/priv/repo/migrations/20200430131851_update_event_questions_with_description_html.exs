defmodule Artemis.Repo.Migrations.UpdateEventQuestionsWithDescriptionHtml do
  use Ecto.Migration

  def change do
    alter table(:event_questions) do
      add :description_html, :text
    end
  end
end
