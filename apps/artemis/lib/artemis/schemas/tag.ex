defmodule Artemis.Tag do
  use Artemis.Schema
  use Assoc.Schema, repo: Artemis.Repo

  schema "tags" do
    field :description, :string
    field :name, :string
    field :slug, :string
    field :type, :string
  end

  # Callbacks

  def updatable_fields,
    do: [
      :description,
      :slug,
      :name,
      :type
    ]

  def required_fields,
    do: [
      :name,
      :slug,
      :type
    ]

  def updatable_associations,
    do: []

  def event_log_fields,
    do: [
      :id,
      :name,
      :slug,
      :type
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
  end
end
