defmodule ArtemisWeb.ProjectView do
  use ArtemisWeb, :view

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Active", "active"},
      {"Team", "team"},
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
      "active" => [
        label: fn _conn -> "Active?" end,
        label_html: fn conn ->
          sortable_table_header(conn, "active", "Active?")
        end,
        value: fn _conn, row -> row.active end
      ],
      "team" => [
        label: fn _conn -> "Team" end,
        value: fn _conn, row -> row.team.name end,
        value_html: fn conn, row ->
          case has?(conn, "teams:show") do
            true -> link(row.team.name, to: Routes.team_path(conn, :show, row.team))
            false -> row.team.name
          end
        end
      ],
      "title" => [
        label: fn _conn -> "Title" end,
        label_html: fn conn ->
          sortable_table_header(conn, "title", "Title")
        end,
        value: fn _conn, row -> row.title end,
        value_html: fn conn, row ->
          case has?(conn, "projects:show") do
            true -> link(row.title, to: Routes.project_path(conn, :show, row))
            false -> row.title
          end
        end
      ]
    }
  end

  defp data_table_actions_column_html(conn, row) do
    allowed_actions = [
      [
        verify: has?(conn, "projects:show"),
        link: link("Show", to: Routes.project_path(conn, :show, row))
      ],
      [
        verify: has?(conn, "projects:update"),
        link: link("Edit", to: Routes.project_path(conn, :edit, row))
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

  def render_show_link(_conn, nil), do: nil

  def render_show_link(conn, record) do
    link(record.title, to: Routes.project_path(conn, :show, record))
  end
end
