defmodule Artemis.Standup do
  use Artemis.Schema

  schema "standups" do
    field :date, :date
    field :past, :string
    field :future, :string
    field :blockers, :string

    belongs_to :team, Artemis.Team
    belongs_to :user, Artemis.User

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :date,
      :past,
      :future,
      :blockers,
      :team_id,
      :user_id
    ]

  def required_fields,
    do: [
      :date,
      :team_id,
      :user_id
    ]

  def event_log_fields,
    do: [
      :date,
      :team_id,
      :user_id
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> unique_constraint(:date, name: :standups_date_team_id_user_id_index)
  end
end
