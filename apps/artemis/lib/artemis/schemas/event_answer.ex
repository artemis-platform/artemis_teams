defmodule Artemis.EventAnswer do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "event_answers" do
    field :date, :date
    field :type, :string
    field :value, :string

    belongs_to :event_question, Artemis.EventQuestion, on_replace: :delete
    belongs_to :project, Artemis.Project, on_replace: :delete
    belongs_to :user, Artemis.User, on_replace: :delete

    has_one :team, through: [:event_question, :event_template, :team]

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :date,
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
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> validate_inclusion(:type, allowed_types())
    |> foreign_key_constraint(:event_question_id)
    |> foreign_key_constraint(:user_id)
  end
end
