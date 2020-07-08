defmodule Artemis.Repo.Migrations.AddVisibilityToEventQuestions do
  use Ecto.Migration

  def change do
    alter table(:event_questions) do
      add :visibility, :string
    end

    create index(:event_questions, [:visibility])
  end
end
