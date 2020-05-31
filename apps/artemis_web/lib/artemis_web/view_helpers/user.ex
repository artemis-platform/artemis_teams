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
  def render_user_name_html(conn, user) do
    case has?(conn, "users:show") do
      true -> content_tag(:a, user.name, href: ArtemisWeb.Router.Helpers.user_path(conn, :show, user.id))
      false -> content_tag(:span, user.name, class: "user-name")
    end
  end
end
