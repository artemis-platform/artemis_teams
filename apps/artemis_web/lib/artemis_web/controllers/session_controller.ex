defmodule ArtemisWeb.SessionController do
  use ArtemisWeb, :controller

  alias ArtemisLog.ListEventLogs
  alias ArtemisLog.ListHttpRequestLogs

  def index(conn, params) do
    authorize(conn, "sessions:list", fn ->
      params = get_index_params(params)
      user = current_user(conn)
      event_logs_by_session_id = ListEventLogs.call(params, user)

      render(conn, "index.html", event_logs_by_session_id: event_logs_by_session_id)
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "sessions:show", fn ->
      params = get_show_params(id)
      user = current_user(conn)
      event_logs = ListEventLogs.call(params, user)
      http_request_logs = ListHttpRequestLogs.call(params, user)

      combined = event_logs ++ http_request_logs
      sorted = Enum.sort_by(combined, & &1.inserted_at)
      session_entries = Enum.reverse(sorted)

      assigns = [
        session_entries: session_entries,
        session_id: id
      ]

      render(conn, "show.html", assigns)
    end)
  end

  # Helpers

  defp get_index_params(params) do
    default_params = %{
      "distinct" => "session_id",
      "page_size" => "10"
    }

    Map.merge(default_params, params)
  end

  defp get_show_params(id) do
    %{
      "filters" => %{
        "session_id" => id
      },
      "paginate" => False
    }
  end
end
