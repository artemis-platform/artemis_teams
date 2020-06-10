defmodule ArtemisWeb.ViewHelper.User do
  use Phoenix.HTML

  import ArtemisWeb.UserAccess

  @doc """
  Render the current user initials from the `user.name` value:

    John Smith -> JS
    JOHN SMITH -> JS
    johN Smith -> JS
    John von Smith -> JVS
    John Smith-Doe -> JSD

  """
  def render_user_initials(%{name: name}) when is_bitstring(name) do
    name
    |> String.replace("-", " ")
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.first(&1))
    |> Enum.join()
    |> String.upcase()
  end

  def render_user_initials(_), do: nil

  @doc """
  Render a user name as a link or a span
  """
  def render_user_name_html(conn_or_socket, user, current_user \\ nil) do
    content_tag(:span, class: "user") do
      case has?(current_user || conn_or_socket, "users:show") do
        true -> content_tag(:a, user.name, href: ArtemisWeb.Router.Helpers.user_path(conn_or_socket, :show, user.id))
        false -> user.name
      end
    end
  end

  @doc """
  Render the name and link of the recognition users in a natural language sentence
  """
  def render_user_sentence(conn, %{users: users}, current_user \\ nil) when is_list(users) do
    content_tag(:span, class: "user-sentence") do
      users
      |> Enum.map(&render_user_name_html(conn, &1, current_user))
      |> Enum.intersperse(", ")
    end
  end
end
