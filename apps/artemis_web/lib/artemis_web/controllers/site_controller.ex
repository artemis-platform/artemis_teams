defmodule ArtemisWeb.SiteController do
  use ArtemisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
