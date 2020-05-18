defmodule Artemis.ListEventReports do
  use Artemis.Context
  use Artemis.ContextReport

  # import Artemis.Ecto.DateMacros
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

  # defp uniq_at_index(data, index) do
  #   data
  #   |> Enum.map(&Enum.at(&1, index))
  #   |> Enum.uniq()
  # end

  # Callbacks

  @impl true
  def get_allowed_reports(_user) do
    [
      :event_instance_engagement_by_date,
      :event_questions_percent_by_date
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

  def get_report(:event_questions_percent_by_date, params, user) do
    data =
      params
      |> get_base_query(user)
      |> join(:left, [ea], project in assoc(ea, :project))
      |> order_by([ea, p], [
        ea.date,
        p.title
      ])
      |> group_by([ea, p], [
        ea.event_question_id,
        ea.date,
        p.title
      ])
      |> select([ea, p], [
        ea.event_question_id,
        ea.date,
        p.title,
        sum(ea.value_number)
      ])
      |> Repo.all()

    data
    |> Enum.group_by(& Enum.at(&1, 0))
    |> Enum.map(fn {event_question_id, rows} ->
      value =
        rows
        |> Enum.group_by(& Enum.at(&1, 1))
        |> Enum.map(fn {date, rows} ->
          value =
            rows
            |> Enum.map(fn [_, _, project_title, total] ->
              total = if total, do: Decimal.to_float(total), else: 0.0
              project_title = project_title || Artemis.EventAnswer.default_project_name()

              {project_title, total}
            end)
            |> Enum.into(%{})

          {date, value}
        end)
        |> Enum.into(%{})

      {event_question_id, value}
    end)
    |> Enum.into(%{})
  end
end
