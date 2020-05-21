defmodule ArtemisWeb.RecognitionView do
  use ArtemisWeb, :view

  import Artemis.Helpers, only: [keys_to_atoms: 2]

  alias Artemis.Permission

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Description", "description"}
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
        value: fn _conn, row -> row.description end,
        value_html: fn _conn, row -> raw(row.description_html) end
      ]
    }
  end

  defp data_table_actions_column_html(conn, row) do
    allowed_actions = [
      [
        verify: has?(conn, "recognitions:show"),
        link: link("Show", to: Routes.recognition_path(conn, :show, row))
      ],
      [
        verify: has?(conn, "recognitions:update"),
        link: link("Edit", to: Routes.recognition_path(conn, :edit, row))
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
end
