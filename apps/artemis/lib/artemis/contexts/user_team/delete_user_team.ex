defmodule Artemis.DeleteUserTeam do
  use Artemis.Context

  alias Artemis.GetUserTeam
  alias Artemis.ListUserTeams
  alias Artemis.Repo

  def call!(id, params \\ %{}, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error deleting user team")
      {:ok, result} -> result
    end
  end

  def call(id, params \\ %{}, user) do
    id
    |> get_record(user)
    |> delete_record(user)
    |> Event.broadcast("user-team:deleted", params, user)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetUserTeam.call(id, user)

  defp delete_record(nil, _), do: {:error, "Record not found"}

  defp delete_record(record, user) do
    case remaining_admin_users?(record, user) do
      true -> Repo.delete(record)
      false -> {:error, "A team must have at least one admin"}
    end
  end

  defp remaining_admin_users?(%{team_id: team_id, user_id: user_id}, user) do
    params = %{
      filters: %{
        team_id: team_id
      }
    }

    params
    |> ListUserTeams.call(user)
    |> Enum.any?(&(&1.type == "admin" && &1.user_id != user_id))
  end
end
