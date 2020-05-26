defmodule Artemis.Repo.Migrations.CreateRecognitions do
  use Ecto.Migration

  def change do
    create table(:recognitions) do
      add :description, :text
      add :description_html, :text

      add :created_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end
  end
end
