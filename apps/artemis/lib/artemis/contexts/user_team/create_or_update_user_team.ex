defmodule Artemis.CreateOrUpdateUserTeam do
  use Artemis.Context

  alias Artemis.CreateUserTeam
  alias Artemis.GetUserTeam
  alias Artemis.UpdateUserTeam

  def call(params, user) do
    case get_record(params, user) do
      nil -> CreateUserTeam.call(params, user)
      record -> UpdateUserTeam.call(record.id, params, user)
    end
  end

  defp get_record(params, user) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.take(["team_id", "user_id"])
    |> Artemis.Helpers.keys_to_atoms()
    |> Enum.into([])
    |> GetUserTeam.call(user)
  end
end
