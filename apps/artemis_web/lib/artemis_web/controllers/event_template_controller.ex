defmodule ArtemisWeb.EventTemplateController do
  use ArtemisWeb, :controller

  alias Artemis.CreateEventTemplate
  alias Artemis.DeleteEventTemplate
  alias Artemis.GetEventTemplate
  alias Artemis.GetTeam
  alias Artemis.ListEventTemplates
  alias Artemis.EventTemplate
  alias Artemis.UpdateEventTemplate

  @preload []

  def index(conn, params) do
    authorize(conn, "event-templates:list", fn ->
      user = current_user(conn)
      team = get_team!(params, user)

      params =
        params
        |> Map.put(:paginate, true)
        |> Map.put(:filters, %{team_id: team.id})

      event_templates = ListEventTemplates.call(params, user)

      render_format(conn, "index", team: team, event_templates: event_templates)
    end)
  end

  def new(conn, params) do
    authorize(conn, "event-templates:create", fn ->
      user = current_user(conn)
      team = get_team!(params, user)
      event_template = %EventTemplate{active: true}
      changeset = EventTemplate.changeset(event_template)

      assigns = [
        changeset: changeset,
        event_template: event_template,
        team: team
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"event_template" => params, "team_id" => team_id}) do
    authorize(conn, "event-templates:create", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      params = Map.put(params, "team_id", team_id)

      case CreateEventTemplate.call(params, user) do
        {:ok, _event_template} ->
          conn
          |> put_flash(:info, "Team member created successfully.")
          |> redirect(to: Routes.team_event_template_path(conn, :index, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_template = %EventTemplate{}

          assigns = [
            changeset: changeset,
            event_template: event_template,
            team: team
          ]

          render(conn, "new.html", assigns)
      end
    end)
  end

  def show(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "event-templates:show", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      event_template = GetEventTemplate.call!(id, user)

      render(conn, "show.html", team: team, event_template: event_template)
    end)
  end

  def edit(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "event-templates:update", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      event_template = GetEventTemplate.call(id, user, preload: @preload)
      changeset = EventTemplate.changeset(event_template)

      assigns = [
        changeset: changeset,
        event_template: event_template,
        team: team
      ]

      render(conn, "edit.html", assigns)
    end)
  end

  def update(conn, %{"id" => id, "event_template" => params, "team_id" => team_id}) do
    authorize(conn, "event-templates:update", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      params = Map.put(params, "team_id", team_id)

      case UpdateEventTemplate.call(id, params, user) do
        {:ok, _event_template} ->
          conn
          |> put_flash(:info, "Team member updated successfully.")
          |> redirect(to: Routes.team_event_template_path(conn, :index, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_template = GetEventTemplate.call(id, user, preload: @preload)

          assigns = [
            changeset: changeset,
            event_template: event_template,
            team: team
          ]

          render(conn, "edit.html", assigns)
      end
    end)
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "event-templates:delete", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)

      {:ok, _event_template} = DeleteEventTemplate.call(id, user)

      conn
      |> put_flash(:info, "Event template removed successfully.")
      |> redirect(to: Routes.team_event_template_path(conn, :index, team))
    end)
  end

  # Helpers

  defp get_team!(%{"team_id" => team_id}, user), do: get_team!(team_id, user)
  defp get_team!(id, user), do: GetTeam.call!(id, user)
end
