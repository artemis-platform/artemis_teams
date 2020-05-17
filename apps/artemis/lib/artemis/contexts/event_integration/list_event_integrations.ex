defmodule Artemis.ListEventIntegrations do
  use Artemis.Context

  use Artemis.ContextCache,
    cache_reset_on_events: [
      "event_integration:created",
      "event_integration:deleted",
      "event_integration:updated"
    ]

  import Artemis.Helpers.Filter
  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.EventIntegration
  alias Artemis.Repo

  @default_order "notification_type,integration_type,inserted_at"
  @default_page_size 25
  @default_preload [:event_template]

  def call(params \\ %{}, user) do
    params = default_params(params)

    EventIntegration
    |> distinct(true)
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

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end
