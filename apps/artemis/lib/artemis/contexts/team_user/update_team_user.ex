defmodule Artemis.UpdateTeamUser do
  use Artemis.Context

  alias Artemis.GetTeamUser
  alias Artemis.Repo
  alias Artemis.TeamUser

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating team user")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params)
      |> Event.broadcast("team-user:updated", user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetTeamUser.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    record
    |> TeamUser.changeset(params)
    |> Repo.update()
  end
end
