defmodule ArtemisWeb.EventIntegrationView do
  use ArtemisWeb, :view

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Active", "active"},
      {"Integration", "integration_type"},
      {"Name", "name"},
      {"Notification Type", "notification_type"},
      {"Schedule", "schedule"},
      {"Upcoming", "upcoming"}
    ]
  end

  def data_table_allowed_columns() do
    %{
      "actions" => [
        label: fn _conn -> nil end,
        value: fn _conn, _row -> nil end,
        value_html: &data_table_actions_column_html/2
      ],
      "active" => [
        label: fn _conn -> "Active" end,
        label_html: fn conn ->
          sortable_table_header(conn, "active", "Active")
        end,
        value: fn _conn, row -> row.active end
      ],
      "integration_type" => [
        label: fn _conn -> "Integration" end,
        label_html: fn conn ->
          sortable_table_header(conn, "integration_type", "Integration")
        end,
        value: fn _conn, row -> row.name end,
        value_html: fn conn, row ->
          case has?(conn, "event-integrations:show") do
            true -> link(row.integration_type, to: Routes.event_integration_path(conn, :show, row.event_template, row))
            false -> row.integration_type
          end
        end
      ],
      "name" => [
        label: fn _conn -> "Name" end,
        label_html: fn conn ->
          sortable_table_header(conn, "name", "Name")
        end,
        value: fn _conn, row -> render_event_integration_name(row) end,
        value_html: fn conn, row ->
          label = render_event_integration_name(row)

          case has?(conn, "event-integrations:show") do
            true -> link(label, to: Routes.event_integration_path(conn, :show, row.event_template, row))
            false -> label
          end
        end
      ],
      "notification_type" => [
        label: fn _conn -> "Notification Type" end,
        label_html: fn conn ->
          sortable_table_header(conn, "notification_type", "Notification Type")
        end,
        value: fn _conn, row -> row.name end,
        value_html: fn conn, row ->
          case has?(conn, "event-integrations:show") do
            true -> link(row.notification_type, to: Routes.event_integration_path(conn, :show, row.event_template, row))
            false -> row.notification_type
          end
        end
      ],
      "schedule" => [
        label: fn _conn -> "Schedule" end,
        value: fn _conn, row -> get_schedule_summary(row.schedule) end
      ],
      "upcoming" => [
        label: fn _conn -> "Upcoming" end,
        value: fn _conn, row -> get_schedule_occurrences(row.schedule, Timex.now(), 3) end
      ]
    }
  end

  defp data_table_actions_column_html(conn, row) do
    allowed_actions = [
      [
        verify: has?(conn, "event-integrations:show"),
        link: link("Show", to: Routes.event_integration_path(conn, :show, row.event_template, row))
      ],
      [
        verify: has?(conn, "event-integrations:update"),
        link: link("Edit", to: Routes.event_integration_path(conn, :edit, row.event_template, row))
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

  # Helpers

  @doc """
  Renders the name value, falling back on notification and integration type if omitted
  """
  def render_event_integration_name(event_integration) do
    fallback = "#{event_integration.notification_type} - #{event_integration.integration_type}"

    event_integration.name || fallback
  end

  @doc """
  Returns the value of a key in the event_integration.settings field
  """
  def get_event_integration_setting(%Ecto.Changeset{} = changeset, key) when is_bitstring(key) do
    changeset
    |> Ecto.Changeset.get_field(:settings)
    |> Kernel.||(%{})
    |> Artemis.Helpers.keys_to_strings()
    |> Map.get(key)
  end

  def render_show_link(_conn, nil), do: nil

  def render_show_link(conn, record) do
    link(record.name, to: Routes.event_integration_path(conn, :show, record.event_template, record))
  end
end
