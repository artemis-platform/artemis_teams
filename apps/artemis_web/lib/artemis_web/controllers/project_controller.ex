defmodule ArtemisWeb.ProjectController do
  use ArtemisWeb, :controller

  alias Artemis.CreateProject
  alias Artemis.Project
  alias Artemis.DeleteProject
  alias Artemis.GetProject
  alias Artemis.GetTeam
  alias Artemis.UpdateProject

  @preload [:team]

  def index(conn, %{"team_id" => team_id}) do
    redirect(conn, to: Routes.team_path(conn, :show, team_id))
  end

  def new(conn, %{"team_id" => team_id}) do
    authorize(conn, "projects:create", fn ->
      user = current_user(conn)
      team = GetTeam.call!(team_id, user)
      project = %Project{team_id: team_id}
      changeset = Project.changeset(project)

      assigns = [
        changeset: changeset,
        project: project,
        team: team
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"project" => params, "team_id" => team_id}) do
    authorize(conn, "projects:create", fn ->
      user = current_user(conn)
      team = GetTeam.call!(team_id, user)
      params = Map.put(params, "team_id", team_id)

      case CreateProject.call(params, user) do
        {:ok, _project} ->
          conn
          |> put_flash(:info, "Project created successfully.")
          |> redirect(to: Routes.team_path(conn, :show, team_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          project = %Project{team_id: team_id}

          assigns = [
            changeset: changeset,
            project: project,
            team: team
          ]

          render(conn, "new.html", assigns)
      end
    end)
  end

  def show(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "projects:show", fn ->
      user = current_user(conn)
      team = GetTeam.call!(team_id, user)
      project = GetProject.call!(id, user, preload: @preload)

      assigns = [
        project: project,
        team: team,
        user: user
      ]

      render(conn, "show.html", assigns)
    end)
  end

  def edit(conn, %{"team_id" => team_id, "id" => id}) do
    authorize(conn, "projects:update", fn ->
      user = current_user(conn)
      team = GetTeam.call!(team_id, user)
      project = GetProject.call(id, user, preload: @preload)
      changeset = Project.changeset(project)

      assigns = [
        changeset: changeset,
        project: project,
        team: team
      ]

      render(conn, "edit.html", assigns)
    end)
  end

  def update(conn, %{"id" => id, "team_id" => team_id, "project" => params}) do
    authorize(conn, "projects:update", fn ->
      user = current_user(conn)
      team = GetTeam.call!(team_id, user)
      params = Map.put(params, "team_id", team_id)

      case UpdateProject.call(id, params, user) do
        {:ok, _project} ->
          conn
          |> put_flash(:info, "Project updated successfully.")
          |> redirect(to: Routes.team_path(conn, :show, team_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          project = GetProject.call(id, user, preload: @preload)

          assigns = [
            changeset: changeset,
            project: project,
            team: team
          ]

          render(conn, "edit.html", assigns)
      end
    end)
  end

  def delete(conn, %{"team_id" => team_id, "id" => id} = params) do
    authorize(conn, "projects:delete", fn ->
      {:ok, _project} = DeleteProject.call(id, params, current_user(conn))

      conn
      |> put_flash(:info, "Project deleted successfully.")
      |> redirect(to: Routes.team_path(conn, :show, team_id))
    end)
  end
end
