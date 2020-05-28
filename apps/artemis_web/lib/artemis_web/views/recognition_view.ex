defmodule ArtemisWeb.RecognitionView do
  use ArtemisWeb, :view

  # Data Table

  def data_table_available_columns() do
    [
      {"Actions", "actions"},
      {"Created By", "created_by"},
      {"Description", "description"},
      {"Users", "users"}
    ]
  end

  def data_table_allowed_columns() do
    %{
      "actions" => [
        label: fn _conn -> nil end,
        value: fn _conn, _row -> nil end,
        value_html: &data_table_actions_column_html/2
      ],
      "created_by" => [
        label: fn _conn -> "Created By" end,
        value: fn _conn, row -> render_created_by(row) end,
        value_html: fn conn, row -> render_created_by(conn, row) end
      ],
      "description" => [
        label: fn _conn -> "Description" end,
        label_html: fn conn ->
          sortable_table_header(conn, "description", "Description")
        end,
        value: fn _conn, row -> row.description end,
        value_html: fn _conn, row -> raw(row.description_html) end
      ],
      "users" => [
        label: fn _conn -> "Users" end,
        value: fn _conn, row -> render_users(row) end,
        value_html: fn conn, row -> render_users_html(conn, row) end
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
  def render_created_by(%{created_by: %Artemis.User{}} = record), do: record.created_by.name
  def render_created_by(_), do: "Unknown"

  @doc """
  Render the name and link of the user who created the recognition
  """
  def render_created_by(conn, %{created_by: %Artemis.User{}} = record) do
    case has?(conn, "users:show") do
      true -> link(record.created_by.name, to: Routes.user_path(conn, :show, record.created_by))
      false -> record.created_by.name
    end
  end

  def render_created_by(_, _), do: "Unknown"

  @doc """
  Render the name of the recognition users
  """
  def render_users(%{users: users}) when is_list(users) do
    users
    |> Enum.map(& &1.name)
    |> Enum.join(",")
  end

  @doc """
  Render the name and link of the recognition users
  """
  def render_users_html(conn, %{users: users}) when is_list(users) do
    Enum.map(users, fn user ->
      content_tag(:div) do
        case has?(conn, "users:show") do
          true -> content_tag(:a, user.name, href: Routes.user_path(conn, :show, user.id))
          false -> user.name
        end
      end
    end)
  end

  @doc """
  Render the name and link of the recognition users in a natural language sentence
  """
  def render_user_sentence(conn, %{users: users}) when is_list(users) do
    users
    |> Enum.map(fn user ->
      content_tag(:span, class: "user") do
        case has?(conn, "users:show") do
          true -> content_tag(:a, user.name, href: Routes.user_path(conn, :show, user.id))
          false -> user.name
        end
      end
    end)
    |> Enum.intersperse(", ")
  end

  @doc """
  Render recognition form with Phoenix LiveView
  """
  def live_render_recognition_form(conn, assigns \\ []) do
    id = Artemis.Helpers.UUID.call()

    session =
      assigns
      |> Enum.into(%{})
      |> Map.put_new(:user, current_user(conn))

    Phoenix.LiveView.live_render(conn, ArtemisWeb.RecognitionFormLive, id: id, session: session)
  end
end