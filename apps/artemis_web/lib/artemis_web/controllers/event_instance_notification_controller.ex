defmodule ArtemisWeb.EventInstanceNotificationController do
  use ArtemisWeb, :controller

  alias Artemis.EventAnswer
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventIntegrations

  def create(conn, %{"event_id" => event_template_id, "event_instance_id" => date}) do
    authorize(conn, "event-integrations:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      case create_event_instance_notification(event_template_id, date, user) do
        {:ok, _event_question} ->
          conn
          |> put_flash(:info, "Event Notification created successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template_id))

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Event Notification creation error.")
          |> redirect(to: Routes.event_instance_path(conn, :show, event_template_id, date))
      end
    end)
  end

  # Helpers

  defp create_event_instance_notification(event_template_id, date, user) do
    {:ok, true}
  end
end
