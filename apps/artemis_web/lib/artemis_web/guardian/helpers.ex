defmodule ArtemisWeb.Guardian.Helpers do
  import Plug.Conn

  alias ArtemisWeb.ErrorView

  @doc """
  Returns the logged in user from conn or assigns
  """
  def current_user(%{"guardian_default_token" => token}) do
    ArtemisWeb.Guardian
    |> Guardian.resource_from_token(token)
    |> elem(1)
  end

  def current_user(%Plug.Conn{} = conn) do
    ArtemisWeb.Guardian.Plug.current_resource(conn)
  end

  def current_user(assigns) do
    cond do
      user = Map.get(assigns, :user) -> user
      conn = Map.get(assigns, :conn) -> current_user(conn)
    end
  end

  @doc """
  Returns boolean if user is logged in
  """
  def current_user?(conn_or_assigns) do
    case current_user(conn_or_assigns) do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Immediately return a 401 unauthorized page
  """
  def render_unauthorized(conn) do
    conn
    |> put_status(401)
    |> Phoenix.Controller.put_view(ErrorView)
    |> Phoenix.Controller.render("401.html", error_page: true)
  end

  @doc """
  Immediately return a 403 unauthorized page
  """
  def render_forbidden(conn) do
    conn
    |> put_status(403)
    |> Phoenix.Controller.put_view(ErrorView)
    |> Phoenix.Controller.render("403.html", error_page: true)
  end

  @doc """
  Immediately redirect to the user log in
  """
  def redirect_to_log_in(conn) do
    path = ArtemisWeb.Router.Helpers.auth_path(conn, :new)
    query_params = "?redirect=#{conn.request_path}"

    conn
    |> ArtemisWeb.Guardian.Plug.sign_out()
    |> Phoenix.Controller.put_flash(:info, "Log in to continue")
    |> Phoenix.Controller.redirect(to: path <> query_params)
  end
end
