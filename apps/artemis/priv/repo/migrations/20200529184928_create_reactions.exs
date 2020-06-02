defmodule Artemis.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :resource_id, :string
      add :resource_type, :string
      add :value, :text
      add :user_id, references(:users, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:reactions, :resource_id)
    create index(:reactions, :resource_type)
    create index(:reactions, [:resource_id, :resource_type])
    create index(:reactions, [:resource_type, :resource_id])
    create index(:reactions, [:value])
  end
end
