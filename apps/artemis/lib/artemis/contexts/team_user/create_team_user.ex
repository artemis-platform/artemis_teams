defmodule Artemis.CreateTeamUser do
  use Artemis.Context

  alias Artemis.Repo
  alias Artemis.TeamUser

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating team user")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("team-user:created", user)
    end)
  end

  defp insert_record(params) do
    %TeamUser{}
    |> TeamUser.changeset(params)
    |> Repo.insert()
  end
end
