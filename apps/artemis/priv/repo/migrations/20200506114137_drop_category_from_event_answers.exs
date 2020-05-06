defmodule Artemis.Repo.Migrations.DropCategoryFromEventAnswers do
  use Ecto.Migration

  def change do
    alter table(:event_answers) do
      remove :category
    end
  end
end
