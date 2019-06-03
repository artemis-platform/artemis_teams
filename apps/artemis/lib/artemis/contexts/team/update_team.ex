defmodule Artemis.UpdateTeam do
  use Artemis.Context

  alias Artemis.GenerateTeamParams
  alias Artemis.GetTeam
  alias Artemis.Repo
  alias Artemis.Team

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating team")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params)
      |> Event.broadcast("team:updated", user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetTeam.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    params = GenerateTeamParams.call(params, record)

    record
    |> Team.changeset(params)
    |> Repo.update()
  end
end
