defmodule Artemis.GetTeam do
  use Artemis.Context

  import Ecto.Query

  alias Artemis.Team
  alias Artemis.Repo

  @default_preload []

  def call!(value, user, options \\ []) do
    get_record(value, user, options, &Repo.get_by!/2)
  end

  def call(value, user, options \\ []) do
    get_record(value, user, options, &Repo.get_by/2)
  end

  defp get_record(value, user, options, get_by) when not is_list(value) do
    get_record([id: value], user, options, get_by)
  end

  defp get_record(value, user, options, get_by) do
    Team
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> restrict_access(user)
    |> get_by.(value)
  end

  defp restrict_access(query, user) do
    cond do
      has?(user, "teams:access:all") -> query
      has?(user, "teams:access:associated") -> restrict_associated_access(query, user)
      true -> where(query, [u], is_nil(u.id))
    end
  end

  defp restrict_associated_access(query, user) do
    query
    |> join(:left, [team], team_users in assoc(team, :team_users))
    |> where([..., tu], tu.user_id == ^user.id)
  end
end
