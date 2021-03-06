defmodule Artemis.ListEventQuestions do
  use Artemis.Context

  use Artemis.ContextCache,
    cache_reset_on_events: [
      "event_question:created",
      "event_question:deleted",
      "event_question:updated"
    ]

  import Artemis.Helpers.Filter
  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.EventQuestion
  alias Artemis.Repo

  @default_order "order,inserted_at"
  @default_page_size 25
  @default_preload [:event_template]

  def call(params \\ %{}, user) do
    params = default_params(params)

    EventQuestion
    |> distinct_query(params, default: true)
    |> preload(^Map.get(params, "preload"))
    |> filter_query(params, user)
    |> search_filter(params)
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

  defp filter(query, "active", value), do: where(query, [i], i.active in ^split(value))
  defp filter(query, "event_template_id", value), do: where(query, [i], i.event_template_id in ^split(value))
  defp filter(query, "title", value), do: where(query, [i], i.title in ^split(value))

  defp filter(query, "user_id", value) do
    query
    |> join(:left, [event_question], event_template in assoc(event_question, :event_template))
    |> join(:left, [..., event_template], user_teams in assoc(event_template, :user_teams))
    |> where([..., user_teams], user_teams.user_id in ^split(value))
  end

  defp filter(query, "visibility", value), do: where(query, [i], i.visibility in ^split(value))

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end
