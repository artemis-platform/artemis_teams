defmodule ArtemisWeb.EventTemplateView do
  use ArtemisWeb, :view

  import ArtemisWeb.UserAccess

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Active", "active"},
      {"Name", "name"},
      {"Slug", "slug"},
      {"Type", "type"}
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
        value: fn _conn, row -> row.active end
      ],
      "name" => [
        label: fn _conn -> "Name" end,
        value: fn _conn, row -> row.name end,
        value_html: fn conn, row ->
          case has?(conn, "teams:show") do
            true -> link(row.name, to: Routes.team_event_template_path(conn, :show, row.team, row))
            false -> row.name
          end
        end
      ],
      "slug" => [
        label: fn _conn -> "Slug" end,
        label_html: fn conn ->
          sortable_table_header(conn, "slug", "Slug")
        end,
        value: fn _conn, row -> row.slug end
      ],
      "type" => [
        label: fn _conn -> "Type" end,
        label_html: fn conn ->
          sortable_table_header(conn, "type", "Type")
        end,
        value: fn _conn, row -> row.type end
      ]
    }
  end

  defp data_table_actions_column_html(conn, row) do
    allowed_actions = [
      [
        verify: has?(conn, "event-templates:show"),
        link: link("Show", to: Routes.team_event_template_path(conn, :show, row.team, row))
      ],
      [
        verify: has?(conn, "event-templates:update"),
        link: link("Edit", to: Routes.team_event_template_path(conn, :edit, row.team, row))
      ],
      [
        verify: has?(conn, "event-templates:delete"),
        link:
          link("Delete",
            to: Routes.team_event_template_path(conn, :delete, row.team, row),
            method: :delete,
            data: [confirm: "Are you sure?"]
          )
      ]
    ]

    Enum.reduce(allowed_actions, [], fn action, acc ->
      case Keyword.get(action, :verify) do
        true -> [acc | Keyword.get(action, :link)]
        _ -> acc
      end
    end)
  end
end
