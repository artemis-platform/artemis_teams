defmodule Artemis.UpdateUserTeam do
  use Artemis.Context

  alias Artemis.GetUserTeam
  alias Artemis.ListUserTeams
  alias Artemis.Repo
  alias Artemis.UserTeam

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating user team")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params, user)
      |> Event.broadcast("user-team:updated", params, user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetUserTeam.call(id, user)

  defp update_record(nil, _params, _user), do: {:error, "Record not found"}

  defp update_record(record, params, user) do
    case remaining_admin_users?(record, params, user) do
      true ->
        record
        |> UserTeam.changeset(params)
        |> Repo.update()

      false ->
        {:error, "A team must have at least one admin"}
    end
  end

  defp remaining_admin_users?(%{team_id: team_id, user_id: user_id}, params, user) do
    params = Artemis.Helpers.keys_to_strings(params)
    type = Map.get(params, "type")
    unchanged? = !type || type == "admin"

    case unchanged? do
      true ->
        true

      false ->
        list_params = %{
          filters: %{
            team_id: team_id
          }
        }

        list_params
        |> ListUserTeams.call(user)
        |> Enum.any?(&(&1.type == "admin" && &1.user_id != user_id))
    end
  end
end
