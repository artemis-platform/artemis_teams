defmodule ArtemisWeb.EventQuestionView do
  use ArtemisWeb, :view

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Active", "active"},
      {"Multiple", "multiple"},
      {"Order", "order"},
      {"Required", "required"},
      {"Title", "title"},
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
        label_html: fn conn ->
          sortable_table_header(conn, "active", "Active")
        end,
        value: fn _conn, row -> row.active end
      ],
      "multiple" => [
        label: fn _conn -> "Multiple" end,
        label_html: fn conn ->
          sortable_table_header(conn, "multiple", "Multiple")
        end,
        value: fn _conn, row -> row.multiple end,
        value_html: fn _conn, row ->
          case row.multiple do
            true -> "Multiple Answers"
            false -> "Single Answer"
          end
        end
      ],
      "order" => [
        label: fn _conn -> "Order" end,
        label_html: fn conn ->
          sortable_table_header(conn, "order", "Order")
        end,
        value: fn _conn, row -> row.order end
      ],
      "required" => [
        label: fn _conn -> "Required" end,
        label_html: fn conn ->
          sortable_table_header(conn, "required", "Required")
        end,
        value: fn _conn, row -> row.required end,
        value_html: fn _conn, row ->
          case row.required do
            true -> "Required"
            false -> "Optional"
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
          case has?(conn, "event-questions:show") do
            true -> link(row.title, to: Routes.event_question_path(conn, :show, row.event_template, row))
            false -> row.title
          end
        end
      ],
      "type" => [
        label: fn _conn -> "Type" end,
        label_html: fn conn ->
          sortable_table_header(conn, "type", "Type")
        end,
        value: fn _conn, row -> row.type end,
        value_html: fn _conn, row -> "#{String.capitalize(row.type)} Field" end
      ]
    }
  end

  defp data_table_actions_column_html(conn, row) do
    allowed_actions = [
      [
        verify: has?(conn, "event-questions:show"),
        link: link("Show", to: Routes.event_question_path(conn, :show, row.event_template, row))
      ],
      [
        verify: has?(conn, "event-questions:update"),
        link: link("Edit", to: Routes.event_question_path(conn, :edit, row.event_template, row))
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
    link(record.title, to: Routes.event_question_path(conn, :show, record.event_template, record))
  end

  @doc """
  Return event question visibility for a given team and user
  """
  def get_event_question_visibility(team_id, user) do
    cond do
      team_admin?(user, team_id) -> Artemis.EventQuestion.get_visibilities("team_admin")
      team_editor?(user, team_id) -> Artemis.EventQuestion.get_visibilities("team_editor")
      team_member?(user, team_id) -> Artemis.EventQuestion.get_visibilities("team_member")
      team_viewer?(user, team_id) -> Artemis.EventQuestion.get_visibilities("team_viewer")
      true -> []
    end
  end

  @doc """
  Return visibility options
  """
  def get_visibility_options() do
    [
      [key: "Entire Team", value: "team_viewer"],
      [key: "Only Team Members and Above", value: "team_member"],
      [key: "Only Team Editors and Above", value: "team_editor"],
      [key: "Only Team Admins", value: "team_admin"]
    ]
  end
end
