defmodule Artemis.Team do
  use Artemis.Schema

  schema "teams" do
    field :active, :boolean, default: false
    field :description, :string
    field :name, :string
    field :slug, :string

    has_many :standups, Artemis.Standup, on_delete: :delete_all
    has_many :team_users, Artemis.TeamUser, on_delete: :delete_all
    has_many :users, through: [:team_users, :user]

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :active,
      :description,
      :name,
      :slug
    ]

  def required_fields,
    do: [
      :slug
    ]

  def event_log_fields,
    do: [
      :id,
      :active,
      :slug
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> unique_constraint(:slug)
  end

  # Queries

  def active?(%Team{} = team), do: team.active

  def active?(slug) do
    case Repo.get_by(Team, slug: slug) do
      nil -> false
      record -> record.active
    end
  end
end
