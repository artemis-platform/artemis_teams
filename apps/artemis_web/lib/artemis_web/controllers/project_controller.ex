defmodule ArtemisWeb.ProjectController do
  use ArtemisWeb, :controller

  alias Artemis.CreateProject
  alias Artemis.Project
  alias Artemis.DeleteProject
  alias Artemis.GetProject
  alias Artemis.GetTeam
  alias Artemis.ListProjects
  alias Artemis.UpdateProject

  @preload [:team]

  def index(conn, params) do
    authorize(conn, "projects:list", fn ->
      user = current_user(conn)
      projects = get_related_projects(params, user)

      assigns = [
        projects: projects
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, params) do
    authorize(conn, "projects:create", fn ->
      project = %Project{team_id: Map.get(params, "team_id")}
      changeset = Project.changeset(project)

      assigns = [
        changeset: changeset,
        project: project
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"project" => params}) do
    authorize(conn, "projects:create", fn ->
      case CreateProject.call(params, current_user(conn)) do
        {:ok, project} ->
          conn
          |> put_flash(:info, "Project created successfully.")
          |> redirect(to: Routes.project_path(conn, :show, project))

        {:error, %Ecto.Changeset{} = changeset} ->
          project = %Project{}

          assigns = [
            changeset: changeset,
            project: project
          ]

          render(conn, "new.html", assigns)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "projects:show", fn ->
      user = current_user(conn)
      project = GetProject.call!(id, user, preload: @preload)
      team = GetTeam.call!(project.team_id, user)

      assigns = [
        project: project,
        team: team,
        user: user
      ]

      authorize_in_team(conn, project.team_id, fn ->
        render(conn, "show.html", assigns)
      end)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "projects:update", fn ->
      user = current_user(conn)
      project = GetProject.call(id, user, preload: @preload)
      team = GetTeam.call!(project.team_id, user)
      changeset = Project.changeset(project)

      assigns = [
        changeset: changeset,
        project: project,
        team: team
      ]

      authorize_in_team(conn, project.team_id, fn ->
        render(conn, "edit.html", assigns)
      end)
    end)
  end

  def update(conn, %{"id" => id, "project" => params}) do
    authorize(conn, "projects:update", fn ->
      user = current_user(conn)
      project = GetProject.call(id, user)

      authorize_in_team(conn, project.team_id, fn ->
        case UpdateProject.call(id, params, user) do
          {:ok, project} ->
            conn
            |> put_flash(:info, "Project updated successfully.")
            |> redirect(to: Routes.project_path(conn, :show, project))

          {:error, %Ecto.Changeset{} = changeset} ->
            project = GetProject.call(id, user, preload: @preload)
            team = GetTeam.call!(project.team_id, user)

            assigns = [
              changeset: changeset,
              project: project,
              team: team
            ]

            render(conn, "edit.html", assigns)
        end
      end)
    end)
  end

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "projects:delete", fn ->
      user = current_user(conn)
      project = GetProject.call(id, user)

      authorize_in_team(conn, project.team_id, fn ->
        {:ok, _project} = DeleteProject.call(id, params, user)

        conn
        |> put_flash(:info, "Project deleted successfully.")
        |> redirect(to: Routes.project_path(conn, :index))
      end)
    end)
  end

  # Helpers

  defp get_related_projects(params, user) do
    required_params = %{
      filters: %{
        user_id: user.id
      },
      paginate: true,
      preload: @preload
    }

    project_params = Map.merge(params, Artemis.Helpers.keys_to_strings(required_params))

    ListProjects.call(project_params, user)
  end
end
