defmodule Artemis.TeamUser do
  use Artemis.Schema

  schema "team_users" do
    field :type, :string

    belongs_to :team, Artemis.Team, on_replace: :delete
    belongs_to :user, Artemis.User, on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :type,
      :team_id,
      :user_id
    ]

  def required_fields,
    do: [
      :type,
      :team_id,
      :user_id
    ]

  def event_log_fields,
    do: [
      :type,
      :team_id,
      :user_id
    ]

  def allowed_types,
    do: [
      "admin",
      "member"
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> validate_inclusion(:type, allowed_types())
    |> unique_constraint(:date, name: :team_users_team_id_user_id_index)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
  end
end
