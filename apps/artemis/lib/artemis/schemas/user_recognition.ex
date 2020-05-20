defmodule Artemis.UserRecognition do
  use Artemis.Schema
  use Artemis.Schema.SQL

  schema "user_recognitions" do
    field :viewed, :boolean, default: false

    belongs_to :recognition, Artemis.Recognition, on_replace: :delete
    belongs_to :user, Artemis.User, on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :recognition_id,
      :user_id
    ]

  def required_fields, do: []

  def event_log_fields,
    do: [
      :recognition_id,
      :user_id
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> foreign_key_constraint(:recognition_id)
    |> foreign_key_constraint(:user_id)
  end
end
