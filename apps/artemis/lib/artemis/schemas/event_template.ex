defmodule Artemis.EventTemplate do
  use Artemis.Schema

  schema "event_templates" do
    field :active, :boolean, default: false
    field :name, :string
    field :slug, :string
    field :type, :string

    belongs_to :team, Artemis.Team, on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :active,
      :name,
      :slug,
      :type,
      :team_id
    ]

  def required_fields,
    do: [
      :active,
      :slug,
      :team_id,
      :type
    ]

  def event_log_fields,
    do: [
      :id,
      :name,
      :slug,
      :type
    ]

  def allowed_types,
    do: [
      "standup"
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> validate_inclusion(:type, allowed_types())
    |> unique_constraint(:slug, name: :event_templates_team_id_slug_index)
    |> foreign_key_constraint(:team_id)
  end

  # Queries

  def active?(%EventTemplate{} = team), do: team.active

  def active?(slug) do
    case Repo.get_by(EventTemplate, slug: slug) do
      nil -> false
      record -> record.active
    end
  end
end
