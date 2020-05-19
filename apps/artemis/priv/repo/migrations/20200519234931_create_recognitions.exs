defmodule Artemis.Repo.Migrations.CreateRecognitions do
  use Ecto.Migration

  def change do
    create table(:recognitions) do
      add :description, :text
      add :description_html, :text
      timestamps(type: :utc_datetime)
    end
  end
end
