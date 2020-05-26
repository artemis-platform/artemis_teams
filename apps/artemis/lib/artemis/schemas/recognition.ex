defmodule Artemis.Recognition do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "recognitions" do
    field :description, :string
    field :description_html, :string

    belongs_to :created_by, Artemis.User, foreign_key: :created_by_id

    has_many :user_recognitions, Artemis.UserRecognition, on_delete: :delete_all, on_replace: :delete
    has_many :users, through: [:user_recognitions, :user]

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :created_by_id,
      :description,
      :description_html
    ]

  def required_fields,
    do: [
      :created_by_id,
      :description
    ]

  def updatable_associations,
    do: [
      user_recognitions: Artemis.UserRecognition
    ]

  def event_log_fields,
    do: [
      :id,
      :created_by_id,
      :description
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> foreign_key_constraint(:created_by)
  end
end
