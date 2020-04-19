defmodule ArtemisWeb.EventController do
  use ArtemisWeb, :controller

  alias Artemis.CreateEventTemplate
  alias Artemis.EventTemplate
  alias Artemis.DeleteEventTemplate
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventQuestions
  alias Artemis.ListEventTemplates
  alias Artemis.UpdateEventTemplate

  @preload [:event_questions, :team]

  def index(conn, params) do
    authorize(conn, "event-templates:list", fn ->
      user = current_user(conn)

      params =
        params
        |> Map.put(:paginate, true)
        |> Map.put(:preload, @preload)

      event_templates = ListEventTemplates.call(params, user)

      assigns = [
        event_templates: event_templates
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "event-templates:create", fn ->
      event_template = %EventTemplate{}
      changeset = EventTemplate.changeset(event_template)

      render(conn, "new.html", changeset: changeset, event_template: event_template)
    end)
  end

  def create(conn, %{"event_template" => params}) do
    authorize(conn, "event-templates:create", fn ->
      case CreateEventTemplate.call(params, current_user(conn)) do
        {:ok, event_template} ->
          conn
          |> put_flash(:info, "EventTemplate created successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_template = %EventTemplate{}

          render(conn, "new.html", changeset: changeset, event_template: event_template)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "event-templates:show", fn ->
      event_template = GetEventTemplate.call!(id, current_user(conn))
      event_questions_params = %{filters: %{event_template_id: event_template.id}}
      event_questions = ListEventQuestions.call(event_questions_params, current_user(conn))

      assigns = [
        event_questions: event_questions,
        event_template: event_template
      ]

      render(conn, "show.html", assigns)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "event-templates:update", fn ->
      event_template = GetEventTemplate.call(id, current_user(conn), preload: @preload)
      changeset = EventTemplate.changeset(event_template)

      render(conn, "edit.html", changeset: changeset, event_template: event_template)
    end)
  end

  def update(conn, %{"id" => id, "event_template" => params}) do
    authorize(conn, "event-templates:update", fn ->
      case UpdateEventTemplate.call(id, params, current_user(conn)) do
        {:ok, event_template} ->
          conn
          |> put_flash(:info, "EventTemplate updated successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_template = GetEventTemplate.call(id, current_user(conn), preload: @preload)

          render(conn, "edit.html", changeset: changeset, event_template: event_template)
      end
    end)
  end

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "event-templates:delete", fn ->
      {:ok, _event_template} = DeleteEventTemplate.call(id, params, current_user(conn))

      conn
      |> put_flash(:info, "EventTemplate deleted successfully.")
      |> redirect(to: Routes.event_path(conn, :index))
    end)
  end
end
