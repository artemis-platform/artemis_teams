defmodule Artemis.Recognition do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "recognitions" do
    field :description, :string
    field :description_html, :string

    has_many :user_recognitions, Artemis.UserRecognition, on_delete: :delete_all, on_replace: :delete
    has_many :users, through: [:user_recognitions, :user]

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :description,
      :description_html
    ]

  def required_fields,
    do: [
      :description
    ]

  def updatable_associations,
    do: [
      user_recognitions: Artemis.UserRecognition
    ]

  def event_log_fields,
    do: [
      :id,
      :description
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
  end
end
