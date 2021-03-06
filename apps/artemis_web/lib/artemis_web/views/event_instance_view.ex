defmodule ArtemisWeb.EventInstanceView do
  use ArtemisWeb, :view

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Date", "date"},
      {"Event Answer", "event_answer"},
      {"Event Answer Percent", "event_answer_percent"},
      {"Event Question", "event_question"},
      {"Project", "project"},
      {"User Email", "user_email"},
      {"User Name", "user_name"}
    ]
  end

  def data_table_allowed_columns() do
    %{
      "actions" => [
        label: fn _conn -> nil end,
        value: fn _conn, _row -> nil end,
        value_html: &data_table_actions_column_html/2
      ],
      "date" => [
        label: fn _conn -> "Date" end,
        value: fn _conn, row -> row.date end
      ],
      "event_answer" => [
        label: fn _conn -> "Event Answer" end,
        value: fn _conn, row -> row.value end,
        value_html: fn _conn, row -> raw(row.value_html || row.value) end
      ],
      "event_answer_percent" => [
        label: fn _conn -> "Event Answer Percent" end,
        value: fn _conn, row -> row.value_percent end
      ],
      "event_question" => [
        label: fn _conn -> "Event Question" end,
        value: fn _conn, row -> Artemis.Helpers.deep_get(row, [:event_question, :title]) end
      ],
      "project" => [
        label: fn _conn -> "Project" end,
        value: fn _conn, row -> Artemis.Helpers.deep_get(row, [:project, :title]) end
      ],
      "user_email" => [
        label: fn _conn -> "User Email" end,
        value: fn _conn, row -> Artemis.Helpers.deep_get(row, [:user, :email]) end
      ],
      "user_name" => [
        label: fn _conn -> "User Name" end,
        value: fn _conn, row -> Artemis.Helpers.deep_get(row, [:user, :name]) end
      ]
    }
  end

  defp data_table_actions_column_html(conn, row) do
    allowed_actions = [
      [
        verify: has?(conn, "event-answers:show"),
        link: link("Show", to: Routes.event_instance_path(conn, :show, row.event_template, row))
      ],
      [
        verify: has?(conn, "event-answers:update"),
        link: link("Edit", to: Routes.event_instance_path(conn, :edit, row.event_template, row))
      ]
    ]

    content_tag(:div, class: "actions") do
      Enum.reduce(allowed_actions, [], fn action, acc ->
        case Keyword.get(action, :verify) do
          true -> [acc | Keyword.get(action, :link)]
          _ -> acc
        end
      end)
    end
  end

  @doc """
  Render event instance form
  """
  def render_event_instance_form(conn, assigns \\ []) do
    session =
      assigns
      |> Map.delete(:conn)
      |> Artemis.Helpers.keys_to_strings()

    live_render(
      conn,
      ArtemisWeb.EventInstanceFormLive,
      session: session
    )
  end

  # Helpers

  def render_show_link(_conn, nil), do: nil

  def render_show_link(conn, record) do
    link(record.title, to: Routes.event_instance_path(conn, :show, record.event_template, record))
  end

  def render_value_html(%{type: "number"} = record) do
    case record.value_percent do
      nil -> "#{record.value_number || record.value}"
      _ -> ["#{record.value_number}", render_value_percent_html(record)]
    end
  end

  def render_value_html(record) do
    value_html = Map.get(record, :value_html)

    case Artemis.Helpers.present?(value_html) do
      true -> raw(value_html)
      false -> record.value
    end
  end

  def render_value_percent(percent) when not is_nil(percent) do
    percent
    |> Decimal.to_float()
    |> Kernel.*(100)
    |> Float.round(1)
  end

  def render_value_percent_html(%{value_percent: percent}) when not is_nil(percent) do
    value = render_value_percent(percent)

    content_tag(:span, "(#{value}%)", class: "percent")
  end

  def render_value_percent_html(_), do: nil

  def render_event_instance_date(date) when is_bitstring(date) do
    date
    |> Date.from_iso8601!()
    |> render_event_instance_date()
  end

  def render_event_instance_date(date) do
    Timex.format!(date, "{WDfull}, {Mfull} {D}, {YYYY}")
  end

  @doc """
  Return the current event instance date
  """
  def get_current_instance_date(event) do
    start_of_day = Timex.beginning_of_day(Timex.now())

    event.schedule
    |> Artemis.Helpers.Schedule.current(start_of_day)
    |> Date.to_iso8601()
  end

  @doc """
  Return the current event instance date
  """
  def get_next_instance_date(event) do
    end_of_day = Timex.end_of_day(Timex.now())

    event.schedule
    |> Artemis.Helpers.Schedule.current(end_of_day)
    |> Date.to_iso8601()
  end

  @doc """
  Filter event answers for event question
  """
  def get_event_answers_for_event_question(event_answers, event_question) do
    event_answers
    |> Enum.filter(&(get_changeset_value(&1, :event_question_id) == event_question.id))
    |> Enum.with_index()
  end

  @doc """
  Return CSS class for event answer
  """
  def get_event_answer_class(event_answer) do
    case get_changeset_value(event_answer, :delete) do
      true -> "event-answer marked-for-deletion"
      _ -> "event-answer"
    end
  end

  @doc """
  Return select options for project field
  """
  def get_options_for_project_field(projects, event_answer) do
    current_project_id = get_changeset_value(event_answer, :project_id)
    project_id_values = Enum.map(projects, &[key: &1.title, value: &1.id])

    deprecated_options_for_select(project_id_values, current_project_id)
  end
end
