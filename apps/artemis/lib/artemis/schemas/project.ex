defmodule Artemis.Project do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "projects" do
    field :active, :boolean, default: true
    field :description, :string
    field :description_html, :string
    field :title, :string

    belongs_to :team, Artemis.Team, on_replace: :delete

    has_many :event_answers, Artemis.EventAnswer, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :active,
      :description,
      :description_html,
      :team_id,
      :title
    ]

  def required_fields,
    do: [
      :team_id,
      :title
    ]

  def updatable_associations,
    do: [
      team: Artemis.Team
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
    |> foreign_key_constraint(:team_id)
  end
end
