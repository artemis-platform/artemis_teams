defmodule Artemis.ListEventAnswers do
  use Artemis.Context

  use Artemis.ContextCache,
    cache_reset_on_events: [
      "event-answer:created",
      "event-answer:deleted",
      "event-answer:updated"
    ]

  import Artemis.Helpers.Filter
  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.EventAnswer
  alias Artemis.Repo

  @default_order "inserted_at"
  @default_page_size 25
  @default_preload [:event_question, :user]

  def call(params \\ %{}, user) do
    params = default_params(params)

    EventAnswer
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

  defp filter(query, "category", value), do: where(query, [i], i.category in ^split(value))
  defp filter(query, "date", value), do: where(query, [i], i.date in ^split(value))
  defp filter(query, "event_question_id", value), do: where(query, [i], i.event_question_id in ^split(value))

  defp filter(query, "event_template_id", value) do
    query
    |> join(:left, [event_answer], event_question in assoc(event_answer, :event_question))
    |> where([..., event_question], event_question.event_template_id in ^split(value))
  end

  defp filter(query, "user_id", value), do: where(query, [i], i.user_id in ^split(value))

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end