defmodule Artemis.Repo.Migrations.CreateEventAnswers do
  use Ecto.Migration

  def change do
    create table(:event_answers) do
      add :category, :string
      add :date, :date
      add :type, :string
      add :value, :text

      add :event_question_id, references(:event_questions, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:event_answers, [:date])
    create index(:event_answers, [:category])
    create index(:event_answers, [:event_question_id, :category])
    create index(:event_answers, [:event_question_id, :date])
    create index(:event_answers, [:event_question_id, :date, :category])
    create index(:event_answers, [:type])
  end
end
