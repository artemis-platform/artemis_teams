defmodule Artemis.EventQuestion do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "event_questions" do
    field :active, :boolean, default: true
    field :description, :string
    field :description_html, :string
    field :multiple, :boolean, default: false
    field :order, :integer
    field :required, :boolean, default: true
    field :title, :string
    field :type, :string
    field :visibility, :string

    belongs_to :event_template, Artemis.EventTemplate, on_replace: :delete

    has_one :team, through: [:event_template, :team]

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :active,
      :description,
      :description_html,
      :event_template_id,
      :multiple,
      :order,
      :required,
      :title,
      :type,
      :visibility
    ]

  def required_fields,
    do: [
      :event_template_id,
      :title,
      :type,
      :visibility
    ]

  def updatable_associations,
    do: [
      event_template: Artemis.EventTemplate
    ]

  def event_log_fields,
    do: [
      :id,
      :title,
      :type,
      :visibility
    ]

  def allowed_types,
    do: [
      "number",
      "text"
    ]

  def allowed_visibilities,
    do: [
      "team_admin",
      "team_member",
      "team_viewer"
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> validate_inclusion(:type, allowed_types())
    |> validate_inclusion(:visibility, allowed_visibilities())
    |> foreign_key_constraint(:event_template_id)
  end
end
