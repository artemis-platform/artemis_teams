defmodule Artemis.Project do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "projects" do
    field :active, :boolean, default: true
    field :description, :string
    field :description_html, :string
    field :title, :string

    has_many :event_answers, Artemis.EventAnswer, on_delete: :delete_all, on_replace: :delete

    many_to_many :teams, Artemis.Team, join_through: "projects_teams", unique: true, on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :active,
      :description,
      :description_html,
      :title
    ]

  def required_fields,
    do: [
      :title
    ]

  def updatable_associations,
    do: [
      teams: Artemis.Team
    ]

  def event_log_fields,
    do: [
      :id,
      :description,
      :title
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
  end
end
