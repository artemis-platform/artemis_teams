defmodule ArtemisWeb.TeamView do
  use ArtemisWeb, :view

  import Artemis.Helpers, only: [keys_to_atoms: 2]

  alias Artemis.Permission

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Description", "description"},
      {"Name", "name"},
      {"User Count", "user_count"}
    ]
  end

  def data_table_allowed_columns() do
    %{
      "actions" => [
        label: fn _conn -> nil end,
        value: fn _conn, _row -> nil end,
        value_html: &data_table_actions_column_html/2
      ],
      "description" => [
        label: fn _conn -> "Description" end,
        label_html: fn conn ->
          sortable_table_header(conn, "description", "Description")
        end,
        value: fn _conn, row -> row.description end
      ],
      "name" => [
        label: fn _conn -> "Name" end,
        label_html: fn conn ->
          sortable_table_header(conn, "name", "Name")
        end,
        value: fn _conn, row -> row.name end,
        value_html: fn conn, row ->
          case has?(conn, "teams:show") && in_team?(conn, row.id) do
            true -> link(row.name, to: Routes.team_path(conn, :show, row))
            false -> row.name
          end
        end
      ],
      "user_count" => [
        label: fn _conn -> "Total Users" end,
        value: fn _conn, row -> row.user_count end,
        value_html: fn conn, row ->
          case has?(conn, "teams:show") && in_team?(conn, row.id) do
            true -> link(row.user_count, to: Routes.team_path(conn, :show, row) <> "#link-users")
            false -> row.user_count
          end
        end
      ]
    }
  end

  defp data_table_actions_column_html(conn, row) do
    allowed_actions = [
      [
        verify: has?(conn, "teams:show") && in_team?(conn, row.id),
        link: link("Show", to: Routes.team_path(conn, :show, row))
      ],
      [
        verify: has?(conn, "teams:update") && team_admin?(conn, row.id),
        link: link("Edit", to: Routes.team_path(conn, :edit, row))
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
  Returns a matching `permission` record based on the passed `permission.id` match value.

  The `permission` data could come from:

  1. The existing record in the database.
  2. The existing form data.

  If the form has not been submitted, it uses the existing record data in the database.

  Once the form is submitted, the existing form data takes precedence. This
  ensures new values are not lost when the form is reloaded after an error.
  """
  def find_permission(match, form, record) do
    existing_permissions = record.permissions

    submitted_permissions =
      case form.params["permissions"] do
        nil -> nil
        values -> Enum.map(values, &struct(Permission, keys_to_atoms(&1, [])))
      end

    permissions = submitted_permissions || existing_permissions

    Enum.find(permissions, fn %{id: id} ->
      id =
        case is_bitstring(id) do
          true -> String.to_integer(id)
          _ -> id
        end

      id == match
    end)
  end

  # Helpers

  def render_show_link(_conn, nil), do: nil

  def render_show_link(conn, record) do
    link(record.name, to: Routes.team_path(conn, :show, record))
  end
end
