defmodule Artemis.Repo.Migrations.UpdateEventPercentInEventAnswers do
  use Ecto.Migration

  def change do
    alter table(:event_answers) do
      modify :value_percent, :decimal
    end
  end
end
