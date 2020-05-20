defmodule Artemis.Repo.Migrations.CreateUserRecognitions do
  use Ecto.Migration

  def change do
    create table(:user_recognitions) do
      add :viewed, :boolean

      add :recognition_id, references(:recognitions, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_recognitions, [:user_id, :recognition_id])
  end
end
