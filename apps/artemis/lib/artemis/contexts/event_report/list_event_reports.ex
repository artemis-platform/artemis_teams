defmodule Artemis.ListEventReports do
  use Artemis.Context
  use Artemis.ContextReport

  import Artemis.Ecto.DateMacros
  import Artemis.Helpers.Filter
  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.EventAnswer
  alias Artemis.Repo

  def call(reports \\ [], params \\ %{}, user) do
    get_reports(reports, params, user)
  end

  # Helpers - Base Query

  defp get_base_query(params, user) do
    EventAnswer
    |> filter_query(params, user)
    |> search_filter(params)
  end

  defp default_params(params), do: Artemis.Helpers.keys_to_strings(params)

  defp filter_query(query, %{"filters" => filters}, _user) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      filter(acc, key, value)
    end)
  end

  defp filter_query(query, _params, _user), do: query

  defp filter(query, _key, nil), do: query
  defp filter(query, _key, ""), do: query

  defp filter(query, "date", value), do: where(query, [i], i.date in ^split(value))
  defp filter(query, "event_question_id", value), do: where(query, [i], i.event_question_id in ^split(value))
  defp filter(query, "project_id", value), do: where(query, [i], i.project_id in ^split(value))

  defp filter(query, "event_template_id", value) do
    query
    |> join(:left, [event_answer], event_question in assoc(event_answer, :event_question))
    |> where([..., event_question], event_question.event_template_id in ^split(value))
  end

  defp filter(query, "user_id", value), do: where(query, [i], i.user_id in ^split(value))

  defp filter(query, _key, _value), do: query

  # Helpers - Data Processing

  defp uniq_at_index(data, index) do
    data
    |> Enum.map(&Enum.at(&1, index))
    |> Enum.uniq()
  end

  # Callbacks

  @impl true
  def get_allowed_reports(_user) do
    [
      :event_instance_engagement_by_date
    ]
  end

  # Callbacks - Reports

  @impl true
  def get_report(:event_instance_engagement_by_date, params, user) do
    params
    |> get_base_query(user)
    |> order_by([ea], ea.date)
    |> group_by([ea], [
      ea.date
    ])
    |> select([ea], [
      ea.date,
      count(ea.user_id, :distinct)
    ])
    |> Repo.all()
  end
end
