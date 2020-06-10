defmodule ArtemisWeb.ViewHelper.Presence do
  use Phoenix.HTML

  import ArtemisWeb.Guardian.Helpers

  @doc """
  Render user presence
  """
  def render_presence(conn, options \\ []) do
    user = Keyword.get(options, :user) || current_user(conn)
    request_path = ArtemisWeb.ViewHelper.Path.get_request_path(conn, options)
    id = "presence-#{request_path}"

    content_tag(:div, class: "presence") do
      Phoenix.LiveView.Helpers.live_render(
        conn,
        ArtemisWeb.PresenceLive,
        id: id,
        session: %{
          "current_user" => user,
          "request_path" => request_path
        }
      )
    end
  end
end
