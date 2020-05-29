defmodule Artemis.Reaction do
  use Artemis.Schema
  use Artemis.Schema.SQL

  schema "reactions" do
    field :resource_id, :string
    field :resource_type, :string
    field :value, :string

    belongs_to :user, Artemis.User

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :resource_id,
      :resource_type,
      :value,
      :user_id
    ]

  def required_fields,
    do: [
      :resource_id,
      :resource_type,
      :value,
      :user_id
    ]

  def event_log_fields,
    do: [
      :id,
      :resource_id,
      :resource_type,
      :value,
      :user_id
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
  end
end
