defmodule ArtemisWeb.RecognitionView do
  use ArtemisWeb, :view

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

  # Helpers

  @doc """
  Render the name of the user who created the recognition
  """
  def render_created_by(conn, %{created_by: %Artemis.User{}} = record) do
    case has?(conn, "users:show") do
      true -> link(record.created_by.name, to: Routes.user_path(conn, :show, record.created_by))
      false -> record.created_by.name
    end
  end

  def render_created_by(_, _), do: "Unknown"
end
