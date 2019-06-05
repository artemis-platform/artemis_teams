defmodule Artemis.ListStandups do
  use Artemis.Context

  import Artemis.Helpers.Filter
  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.Standup

  @default_order "date"
  @default_page_size 10
  @default_preload [:team, :user]

  def call(params \\ %{}, user) do
    params = default_params(params)

    Standup
    |> preload(^Map.get(params, "preload"))
    |> search_filter(params)
    |> filter_query(params, user)
    |> order_query(params)
    |> get_records(params)
  end

  defp default_params(params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put_new("order", @default_order)
    |> Map.put_new("page_size", @default_page_size)
    |> Map.put_new("preload", @default_preload)
  end

  defp filter_query(query, %{"filters" => filters}, _user) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      filter(acc, key, value)
    end)
  end

  defp filter_query(query, _params, _user), do: query

  defp filter(query, _key, nil), do: query
  defp filter(query, _key, ""), do: query
  defp filter(query, "date", value), do: where(query, [s], s.date in ^split(value))
  defp filter(query, "team_id", value), do: where(query, [s], s.team_id in ^split(value))
  defp filter(query, _key, _value), do: query

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end
