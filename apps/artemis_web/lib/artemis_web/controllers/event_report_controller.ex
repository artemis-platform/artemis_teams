defmodule ArtemisWeb.EventReportController do
  use ArtemisWeb, :controller

  alias Artemis.GetEventTemplate

  def index(conn, %{"event_id" => event_template_id}) do
    authorize(conn, "event-reports:list", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      assigns = [
        event_template: event_template
      ]

      render_format(conn, "index", assigns)
    end)
  end
end
