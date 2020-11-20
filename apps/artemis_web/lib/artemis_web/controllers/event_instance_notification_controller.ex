defmodule ArtemisWeb.EventInstanceNotificationController do
  use ArtemisWeb, :controller

  alias Artemis.GetEventTemplate
  alias ArtemisNotify.CreateEventIntegrationNotification

  def create(conn, %{"event_id" => event_template_id, "event_instance_id" => date, "id" => id}) do
    authorize(conn, "event-integrations:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      authorize_in_team(conn, event_template.team_id, fn ->
        case CreateEventIntegrationNotification.call(id, date, user) do
          {:ok, _response} ->
            conn
            |> put_flash(:info, "Event Notification created successfully.")
            |> redirect(to: Routes.event_instance_path(conn, :show, event_template.id, date))

          {:error, _error} ->
            conn
            |> put_flash(:error, "Error creating Event Notification.")
            |> redirect(to: Routes.event_instance_path(conn, :show, event_template.id, date))
        end
      end)
    end)
  end
end
