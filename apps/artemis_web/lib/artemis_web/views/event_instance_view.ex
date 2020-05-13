defmodule ArtemisWeb.EventInstanceView do
  use ArtemisWeb, :view

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Title", "title"}
    ]
  end

  def data_table_allowed_columns() do
    %{
      "actions" => [
        label: fn _conn -> nil end,
        value: fn _conn, _row -> nil end,
        value_html: &data_table_actions_column_html/2
      ],
      "title" => [
        label: fn _conn -> "Title" end,
        label_html: fn conn ->
          sortable_table_header(conn, "title", "Title")
        end,
        value: fn _conn, row -> row.title end,
        value_html: fn conn, row ->
          case has?(conn, "event-answers:show") do
            true -> link(row.title, to: Routes.event_instance_path(conn, :show, row.event_template, row))
            false -> row.title
          end
        end
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
    session = Map.delete(assigns, :conn)

    Phoenix.LiveView.live_render(
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

  def render_value_html(record) do
    value_html = Map.get(record, :value_html)

    case Artemis.Helpers.present?(value_html) do
      true -> raw(value_html)
      false -> record.value
    end
  end

  def render_value_slack(record) do
    convert_html_to_slack_markdown!(record.value_html)
  rescue
    _ -> record.value
  end

  def render_event_instance_date(date) when is_bitstring(date) do
    date
    |> Date.from_iso8601!()
    |> render_event_instance_date()
  end

  def render_event_instance_date(date) do
    Timex.format!(date, "{WDfull}, {Mfull} {D}, {YYYY}")
  end
end
