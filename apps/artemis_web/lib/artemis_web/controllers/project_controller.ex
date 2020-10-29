defmodule ArtemisWeb.ProjectController do
  use ArtemisWeb, :controller

  alias Artemis.CreateProject
  alias Artemis.Project
  alias Artemis.DeleteProject
  alias Artemis.GetProject
  alias Artemis.GetTeam
  alias Artemis.ListProjects
  alias Artemis.ListTeams
  alias Artemis.UpdateProject

  @preload [:teams]

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
      user = current_user(conn)
      project = %Project{teams: Map.get(params, "teams")}
      changeset = Project.changeset(project)
      team_options = get_related_team_options(user)

      assigns = [
        changeset: changeset,
        project: project,
        team_options: team_options
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"project" => params}) do
    authorize(conn, "projects:create", fn ->
      user = current_user(conn)

      case CreateProject.call(params, user) do
        {:ok, project} ->
          conn
          |> put_flash(:info, "Project created successfully.")
          |> redirect(to: Routes.project_path(conn, :show, project))

        {:error, %Ecto.Changeset{} = changeset} ->
          project = %Project{}
          team_options = get_related_team_options(user)

          assigns = [
            changeset: changeset,
            project: project,
            team_options: team_options
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
      team_options = get_related_team_options(user)

      assigns = [
        changeset: changeset,
        project: project,
        team: team,
        team_options: team_options
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
            team_options = get_related_team_options(user)

            assigns = [
              changeset: changeset,
              project: project,
              team: team,
              team_options: team_options
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

  defp get_related_team_options(user) do
    types = [
      "admin",
      "editor"
    ]

    team_ids =
      user
      |> Map.get(:user_teams)
      |> Enum.filter(&Enum.member?(types, &1.type))
      |> Enum.map(& &1.team_id)

    params = %{
      filters: %{
        id: team_ids
      }
    }

    params
    |> ListTeams.call(user)
    |> Enum.map(&[key: &1.name, value: &1.id])
  end
end
