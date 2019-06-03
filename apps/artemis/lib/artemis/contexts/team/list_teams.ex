defmodule Artemis.ListTeams do
  use Artemis.Context

  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.Team
  alias Artemis.Repo

  @default_order "slug"
  @default_page_size 25
  @default_preload []

  def call(params \\ %{}, user) do
    params = default_params(params)

    Team
    |> preload(^Map.get(params, "preload"))
    |> search_filter(params)
    |> order_query(params)
    |> restrict_access(user)
    |> get_records(params)
  end

  defp default_params(params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put_new("order", @default_order)
    |> Map.put_new("page_size", @default_page_size)
    |> Map.put_new("preload", @default_preload)
  end

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)

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
