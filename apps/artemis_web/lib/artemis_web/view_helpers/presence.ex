defmodule ArtemisWeb.ViewHelper.Presence do
  use Phoenix.HTML

  import ArtemisWeb.Guardian.Helpers

  @doc """
  Render user presence
  """
  def render_presence(conn, options \\ []) do
    id = "presence-#{Artemis.Helpers.UUID.call()}"
    user = Keyword.get(options, :user, current_user(conn))

    content_tag(:div, class: "presence") do
      Phoenix.LiveView.Helpers.live_render(
        conn,
        ArtemisWeb.PresenceLive,
        id: id,
        session: %{
          "current_user" => user,
          "request_path" => get_request_path(conn, options)
        }
      )
    end
  end

  defp get_request_path(conn, options) do
    cond do
      path = Keyword.get(options, :path) -> path
      url = Keyword.get(options, :url) -> URI.parse(url).path
      true -> Map.get(conn, :request_path)
    end
  end
end
