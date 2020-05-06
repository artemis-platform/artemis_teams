defmodule Artemis.Repo.Migrations.AddProjectIdToEventAnswers do
  use Ecto.Migration

  def change do
    alter table(:event_answers) do
      add :project_id, references(:projects, on_delete: :delete_all)
    end
  end
end
