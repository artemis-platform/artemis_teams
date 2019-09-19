defmodule ArtemisWeb.TeamUserView do
  use ArtemisWeb, :view

  import ArtemisWeb.UserAccess

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Email", "Email"},
      {"Name", "name"},
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
      "email" => [
        label: fn _conn -> "Email" end,
        value: fn _conn, row -> row.user.email end
      ],
      "name" => [
        label: fn _conn -> "Name" end,
        value: fn _conn, row -> row.user.name end,
        value_html: fn conn, row ->
          case has?(conn, "users:show") do
            true -> link(row.user.name, to: Routes.user_path(conn, :show, row.user))
            false -> row.user.name
          end
        end
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
        verify: has?(conn, "team-users:show"),
        link: link("Show", to: Routes.team_user_path(conn, :show, row.team, row))
      ],
      [
        verify: has?(conn, "team-users:update"),
        link: link("Edit", to: Routes.team_user_path(conn, :edit, row.team, row))
      ],
      [
        verify: has?(conn, "team-users:delete"),
        link:
          link("Delete",
            to: Routes.team_user_path(conn, :delete, row.team, row),
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
