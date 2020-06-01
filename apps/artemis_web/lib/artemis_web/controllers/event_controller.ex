defmodule ArtemisWeb.EventController do
  use ArtemisWeb, :controller

  alias Artemis.CreateEventTemplate
  alias Artemis.EventTemplate
  alias Artemis.DeleteEventTemplate
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventIntegrations
  alias Artemis.ListEventQuestions
  alias Artemis.ListEventTemplates
  alias Artemis.UpdateEventTemplate

  @preload [:event_questions, :team]

  def index(conn, params) do
    authorize(conn, "event-templates:list", fn ->
      user = current_user(conn)
      event_templates = get_related_event_templates(params, user)

      assigns = [
        event_templates: event_templates
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, params) do
    authorize(conn, "event-templates:create", fn ->
      event_template = %EventTemplate{}
      changeset = EventTemplate.changeset(event_template, params)

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
      user = current_user(conn)
      event_template = GetEventTemplate.call!(id, user)

      event_questions_params = %{filters: %{active: true, event_template_id: event_template.id}}
      event_questions = ListEventQuestions.call(event_questions_params, user)

      event_integrations_params = %{filters: %{active: true, event_template_id: event_template.id}}
      event_integrations = ListEventIntegrations.call(event_integrations_params, user)

      assigns = [
        event_integrations: event_integrations,
        event_questions: event_questions,
        event_template: event_template
      ]

      authorize_in_team(conn, event_template.team_id, fn ->
        render(conn, "show.html", assigns)
      end)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "event-templates:update", fn ->
      event_template = GetEventTemplate.call(id, current_user(conn), preload: @preload)
      changeset = EventTemplate.changeset(event_template)

      authorize_team_admin(conn, event_template.team_id, fn ->
        render(conn, "edit.html", changeset: changeset, event_template: event_template)
      end)
    end)
  end

  def update(conn, %{"id" => id, "event_template" => params}) do
    authorize(conn, "event-templates:update", fn ->
      authorize_team_admin(conn, params["team_id"], fn ->
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
    end)
  end

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "event-templates:delete", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call(id, user)

      authorize_team_admin(conn, event_template.team_id, fn ->
        {:ok, _event_template} = DeleteEventTemplate.call(id, params, user)

        conn
        |> put_flash(:info, "Event Template deleted successfully.")
        |> redirect(to: Routes.event_path(conn, :index))
      end)
    end)
  end

  # Helpers

  defp get_related_event_templates(params, user) do
    required_params = %{
      filters: %{
        user_id: user.id
      },
      paginate: true,
      preload: @preload
    }

    event_template_params = Map.merge(params, Artemis.Helpers.keys_to_strings(required_params))

    ListEventTemplates.call(event_template_params, user)
  end
end
