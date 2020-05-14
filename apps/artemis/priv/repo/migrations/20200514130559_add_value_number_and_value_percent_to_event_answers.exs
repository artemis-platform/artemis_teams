defmodule Artemis.Repo.Migrations.AddValueNumberAndValuePercentToEventAnswers do
  use Ecto.Migration

  def change do
    alter table(:event_answers) do
      add :value_number, :numeric
      add :value_percent, :integer
    end

    create index(:event_answers, :value_number)
    create index(:event_answers, :value_percent)
  end
end
