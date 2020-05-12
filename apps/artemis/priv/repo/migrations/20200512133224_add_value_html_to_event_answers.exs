defmodule Artemis.Repo.Migrations.AddValueHtmlToEventAnswers do
  use Ecto.Migration

  def change do
    alter table(:event_answers) do
      add :value_html, :text
    end
  end
end
