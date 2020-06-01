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
        verify: can_update_recognition?(conn, row),
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
  def render_created_by(conn, record, current_user \\ nil)

  def render_created_by(conn, %{created_by: %Artemis.User{}} = record, current_user) do
    case has?(current_user || conn, "users:show") do
      true -> link(record.created_by.name, to: Routes.user_path(conn, :show, record.created_by))
      false -> record.created_by.name
    end
  end

  def render_created_by(_, _, _), do: "Unknown"

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
  def render_users_html(conn, %{users: users}, current_user \\ nil) when is_list(users) do
    Enum.map(users, fn user ->
      content_tag(:div) do
        case has?(current_user || conn, "users:show") do
          true -> content_tag(:a, user.name, href: Routes.user_path(conn, :show, user.id))
          false -> user.name
        end
      end
    end)
  end

  @doc """
  Render the name and link of the recognition users in a natural language sentence
  """
  def render_user_sentence(conn, %{users: users}, current_user \\ nil) when is_list(users) do
    users
    |> Enum.map(fn user ->
      content_tag(:span, class: "user") do
        case has?(current_user || conn, "users:show") do
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
    id = "recognition-form-#{Artemis.Helpers.UUID.call()}"

    session =
      assigns
      |> Enum.into(%{})
      |> Map.put_new(:user, current_user(conn))
      |> Artemis.Helpers.keys_to_strings()

    live_render(conn, ArtemisWeb.RecognitionFormLive, id: id, session: session)
  end

  @doc """
  Render recognition cards with Phoenix LiveView
  """
  def live_render_recognition_cards(conn, assigns \\ []) do
    id = "recognition-cards-#{Artemis.Helpers.UUID.call()}"

    session =
      assigns
      |> Enum.into(%{})
      |> Map.put_new(:user, current_user(conn))
      |> Artemis.Helpers.keys_to_strings()

    live_render(conn, ArtemisWeb.RecognitionCardsLive, id: id, session: session)
  end

  @doc """
  Checks if user is has permissions to update record
  """
  def can_update_recognition?(%Plug.Conn{} = conn, record) do
    conn
    |> current_user()
    |> can_update_recognition?(record)
  end

  def can_update_recognition?(user, record) do
    owner? = record.created_by_id == user.id

    cond do
      has_all?(user, ["recognitions:update", "recognitions:access:all"]) -> true
      has_all?(user, ["recognitions:update", "recognitions:access:self"]) && owner? -> true
      true -> false
    end
  end

  @doc """
  Checks if user is has permissions to delete record
  """
  def can_delete_recognition?(%Plug.Conn{} = conn, record) do
    conn
    |> current_user()
    |> can_delete_recognition?(record)
  end

  def can_delete_recognition?(conn, record) do
    user = current_user(conn)
    owner? = record.created_by_id == user.id

    cond do
      has_all?(user, ["recognitions:delete", "recognitions:access:all"]) -> true
      has_all?(user, ["recognitions:delete", "recognitions:access:self"]) && owner? -> true
      true -> false
    end
  end
end
