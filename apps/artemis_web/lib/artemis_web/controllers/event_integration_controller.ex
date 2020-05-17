defmodule ArtemisWeb.EventIntegrationController do
  use ArtemisWeb, :controller

  alias Artemis.CreateEventIntegration
  alias Artemis.EventIntegration
  alias Artemis.DeleteEventIntegration
  alias Artemis.GetEventIntegration
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventIntegrations
  alias Artemis.UpdateEventIntegration

  @preload [:event_template]

  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-integrations:list", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      params =
        params
        |> Map.put(:paginate, true)
        |> Map.put(:preload, @preload)

      event_integrations = ListEventIntegrations.call(params, user)

      assigns = [
        event_integrations: event_integrations,
        event_template: event_template
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, %{"event_id" => event_template_id}) do
    authorize(conn, "event-integrations:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_integration = %EventIntegration{event_template_id: event_template_id}
      changeset = EventIntegration.changeset(event_integration)

      assigns = [
        changeset: changeset,
        event_integration: event_integration,
        event_template: event_template
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"event_integration" => params, "event_id" => event_template_id}) do
    authorize(conn, "event-integrations:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      case CreateEventIntegration.call(params, user) do
        {:ok, _event_integration} ->
          conn
          |> put_flash(:info, "Event Integration created successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_integration = %EventIntegration{event_template_id: event_template_id}

          assigns = [
            changeset: changeset,
            event_integration: event_integration,
            event_template: event_template
          ]

          render(conn, "new.html", assigns)
      end
    end)
  end

  def show(conn, %{"event_id" => event_template_id, "id" => id}) do
    authorize(conn, "event-integrations:show", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_integration = GetEventIntegration.call!(id, user, preload: @preload)

      assigns = [
        event_integration: event_integration,
        event_template: event_template
      ]

      render(conn, "show.html", assigns)
    end)
  end

  def edit(conn, %{"event_id" => event_template_id, "id" => id}) do
    authorize(conn, "event-integrations:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_integration = GetEventIntegration.call(id, user, preload: @preload)
      changeset = EventIntegration.changeset(event_integration)

      assigns = [
        changeset: changeset,
        event_integration: event_integration,
        event_template: event_template
      ]

      render(conn, "edit.html", assigns)
    end)
  end

  def update(conn, %{"id" => id, "event_id" => event_template_id, "event_integration" => params}) do
    authorize(conn, "event-integrations:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      case UpdateEventIntegration.call(id, params, user) do
        {:ok, _event_integration} ->
          conn
          |> put_flash(:info, "Event Integration updated successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_integration = GetEventIntegration.call(id, user, preload: @preload)

          assigns = [
            changeset: changeset,
            event_integration: event_integration,
            event_template: event_template
          ]

          render(conn, "edit.html", assigns)
      end
    end)
  end

  def delete(conn, %{"event_id" => event_template_id, "id" => id} = params) do
    authorize(conn, "event-integrations:delete", fn ->
      {:ok, _event_integration} = DeleteEventIntegration.call(id, params, current_user(conn))

      conn
      |> put_flash(:info, "Event Integration deleted successfully.")
      |> redirect(to: Routes.event_path(conn, :show, event_template_id))
    end)
  end
end
