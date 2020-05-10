defmodule Artemis.EventAnswer do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "event_answers" do
    field :date, :date
    field :type, :string
    field :value, :string

    field :changeset_id, :string, virtual: true
    field :delete, :boolean, default: false, virtual: true

    belongs_to :event_question, Artemis.EventQuestion, on_replace: :delete
    belongs_to :project, Artemis.Project, on_replace: :delete
    belongs_to :user, Artemis.User, on_replace: :delete

    has_one :team, through: [:event_question, :event_template, :team]

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :changeset_id,
      :date,
      :delete,
      :event_question_id,
      :project_id,
      :type,
      :user_id,
      :value
    ]

  def required_fields,
    do: [
      :event_question_id,
      :type,
      :value,
      :user_id
    ]

  def updatable_associations,
    do: [
      event_question: Artemis.EventQuestion,
      project: Artemis.Project,
      user: Artemis.User
    ]

  def event_log_fields,
    do: [
      :id,
      :date,
      :event_question_id,
      :project_id,
      :type,
      :value,
      :user_id
    ]

  def allowed_types,
    do: [
      "text"
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    params = get_changeset_params(params)

    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> validate_inclusion(:type, allowed_types())
    |> foreign_key_constraint(:event_question_id)
    |> foreign_key_constraint(:user_id)
  end

  # Helpers

  defp get_changeset_params(params) do
    existing =
      params
      |> Artemis.Helpers.keys_to_strings()
      |> Map.get("changeset_id")

    case Artemis.Helpers.present?(existing) do
      false -> Map.put(params, "changeset_id", Artemis.Helpers.UUID.call())
      true -> params
    end
  end
end
