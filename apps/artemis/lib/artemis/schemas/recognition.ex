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
    params = Artemis.Helpers.keys_to_strings(params)

    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> validate_at_least_one_user_recognition(params)
    |> validate_created_by_not_in_user_recognitions(params)
    |> foreign_key_constraint(:created_by)
  end

  # Validators

  defp validate_at_least_one_user_recognition(changeset, params) do
    user_recognitions = Map.get(params, "user_recognitions", Ecto.Changeset.get_field(changeset, :user_recognitions))

    case is_list(user_recognitions) && length(user_recognitions) > 0 do
      false -> add_error(changeset, :user_recognitions, "can't be blank")
      true -> changeset
    end
  end

  defp validate_created_by_not_in_user_recognitions(changeset, params) do
    user_recognitions = Map.get(params, "user_recognitions", Ecto.Changeset.get_field(changeset, :user_recognitions))
    created_by_id = Ecto.Changeset.get_field(changeset, :created_by_id)

    included? =
      Enum.any?(user_recognitions, fn user_recognition ->
        user_id =
          user_recognition
          |> Artemis.Helpers.keys_to_strings()
          |> Map.get("user_id")

        user_id == created_by_id
      end)

    case included? do
      true -> add_error(changeset, :user_recognitions, "can't include creator")
      false -> changeset
    end
  end
end
