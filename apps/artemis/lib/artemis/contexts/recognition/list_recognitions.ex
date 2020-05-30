defmodule Artemis.ListRecognitions do
  use Artemis.Context

  import Artemis.Helpers.Filter
  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.Recognition

  @default_order "-inserted_at"
  @default_page_size 25
  @default_preload []

  def call(params \\ %{}, user) do
    params = default_params(params)

    Recognition
    |> distinct(true)
    |> preload(^Map.get(params, "preload"))
    |> filter_query(params, user)
    |> search_filter(params)
    |> order_query(params)
    |> select_count(params)
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

  defp filter(query, "created_by_id", value), do: where(query, [i], i.created_by_id in ^split(value))
  defp filter(query, "inserted_at", value), do: where(query, [i], i.inserted_at in ^split(value))
  defp filter(query, "inserted_at_gt", value), do: where(query, [i], i.inserted_at > ^value)
  defp filter(query, "inserted_at_gte", value), do: where(query, [i], i.inserted_at >= ^value)
  defp filter(query, "inserted_at_lt", value), do: where(query, [i], i.inserted_at < ^value)
  defp filter(query, "inserted_at_lte", value), do: where(query, [i], i.inserted_at <= ^value)

  defp filter(query, "user_id", value) do
    query
    |> join(:left, [recognitions], user_recognitions in assoc(recognitions, :user_recognitions))
    |> where([..., user_recognitions], user_recognitions.user_id in ^split(value))
  end

  defp filter(query, _key, _value), do: query

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end
