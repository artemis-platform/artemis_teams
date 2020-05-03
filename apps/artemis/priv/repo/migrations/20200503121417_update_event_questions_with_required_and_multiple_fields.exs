defmodule Artemis.Repo.Migrations.UpdateEventQuestionsWithRequiredAndMultipleFields do
  use Ecto.Migration

  def change do
    alter table(:event_questions) do
      add :multiple, :boolean
      add :required, :boolean
    end
  end
end
