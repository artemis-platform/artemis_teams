defmodule Artemis.ListTeams do
  use Artemis.Context

  import Artemis.Helpers.Filter
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
    |> select_fields()
    |> preload(^Map.get(params, "preload"))
    |> search_filter(params)
    |> filter_query(params, user)
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

  defp select_fields(query) do
    query
    |> group_by([t], t.id)
    |> distinct(true)
    |> join(:left, [team], team_users in assoc(team, :team_users))
    |> select([team, ..., team_users], %Team{team | team_user_count: count(team_users.id)})
  end

  defp filter_query(query, %{"filters" => filters}, _user) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      filter(acc, key, value)
    end)
  end

  defp filter_query(query, _params, _user), do: query

  defp filter(query, _key, nil), do: query
  defp filter(query, _key, ""), do: query

  defp filter(query, "user_id", value) do
    query
    |> join(:left, [team], team_users in assoc(team, :team_users))
    |> where([team, ..., team_users], team_users.user_id in ^split(value))
  end

  defp filter(query, _key, _value), do: query

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

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end
