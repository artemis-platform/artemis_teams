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

  @default_order "-date,-inserted_at"
  @default_page_size 25
  @default_preload [:event_question, :user]

  def call(params \\ %{}, user) do
    params = default_params(params)

    EventAnswer
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

  defp filter_query(query, %{"filters" => filters}, user) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      filter(acc, key, value, user)
    end)
  end

  defp filter_query(query, _params, _user), do: query

  defp filter(query, "date", value, _user), do: where(query, [i], i.date in ^split(value))
  defp filter(query, "event_question_id", value, _user), do: where(query, [i], i.event_question_id in ^split(value))
  defp filter(query, "project_id", value, _user), do: where(query, [i], i.project_id in ^split(value))

  defp filter(query, "event_question_visibility", value, _user) do
    query
    |> join(:left, [event_answer], event_question in assoc(event_answer, :event_question))
    |> where([event_answer, event_question], event_question.visibility in ^split(value))
  end

  defp filter(query, "event_question_visibility_or_user_id", value, user) do
    query
    |> join(:left, [event_answer], event_question in assoc(event_answer, :event_question))
    |> where([event_answer, event_question], event_question.visibility in ^split(value) or event_answer.user_id == ^user.id)
  end

  defp filter(query, "event_template_id", value, _user) do
    query
    |> join(:left, [event_answer], event_question in assoc(event_answer, :event_question))
    |> where([..., event_question], event_question.event_template_id in ^split(value))
  end

  defp filter(query, "team_member_id", value, _user) do
    query
    |> join(:left, [event_answer], event_question in assoc(event_answer, :event_question))
    |> join(:left, [..., event_question], event_template in assoc(event_question, :event_template))
    |> join(:left, [..., event_template], user_teams in assoc(event_template, :user_teams))
    |> where([..., user_teams], user_teams.user_id in ^split(value))
  end

  defp filter(query, "user_id", value, _user), do: where(query, [i], i.user_id in ^split(value))

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end
