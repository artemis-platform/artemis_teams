defmodule ArtemisWeb.TeamController do
  use ArtemisWeb, :controller

  use ArtemisWeb.Controller.EventLogsIndex,
    path: &Routes.team_path/3,
    permission: "teams:list",
    resource_type: "Team"

  use ArtemisWeb.Controller.EventLogsShow,
    path: &Routes.team_event_log_path/4,
    permission: "teams:show",
    resource_getter: &Artemis.GetTeam.call!/2,
    resource_id: "team_id",
    resource_type: "Team",
    resource_variable: :team

  alias Artemis.CreateTeam
  alias Artemis.DeleteTeam
  alias Artemis.GetTeam
  alias Artemis.ListEventTemplates
  alias Artemis.ListProjects
  alias Artemis.ListTeams
  alias Artemis.ListUserTeams
  alias Artemis.Team
  alias Artemis.UpdateTeam

  @preload []

  def index(conn, params) do
    authorize(conn, "teams:list", fn ->
      user = current_user(conn)
      params = Map.put(params, :paginate, true)
      teams = ListTeams.call(params, user)

      assigns = [
        teams: teams
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "teams:create", fn ->
      team = %Team{}
      changeset = Team.changeset(team)

      render(conn, "new.html", changeset: changeset, team: team)
    end)
  end

  def create(conn, %{"team" => params}) do
    authorize(conn, "teams:create", fn ->
      user = current_user(conn)
      create_params = get_create_params(params, user)

      case CreateTeam.call(create_params, user) do
        {:ok, team} ->
          conn
          |> put_flash(:info, "Team created successfully.")
          |> redirect(to: Routes.team_path(conn, :show, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          team = %Team{}

          render(conn, "new.html", changeset: changeset, team: team)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "teams:show", fn ->
      user = current_user(conn)
      team = GetTeam.call!(id, current_user(conn))
      event_templates = get_event_templates(id, user)
      projects = get_projects(id, user)
      user_teams = get_user_teams(id, user)

      assigns = [
        event_templates: event_templates,
        projects: projects,
        team: team,
        user_teams: user_teams
      ]

      authorize_in_team(conn, team.id, fn ->
        render(conn, "show.html", assigns)
      end)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "teams:update", fn ->
      team = GetTeam.call!(id, current_user(conn), preload: @preload)
      changeset = Team.changeset(team)

      authorize_team_editor(conn, team.id, fn ->
        render(conn, "edit.html", changeset: changeset, team: team)
      end)
    end)
  end

  def update(conn, %{"id" => id, "team" => params}) do
    authorize(conn, "teams:update", fn ->
      user = current_user(conn)
      team = GetTeam.call!(id, user)

      update_params =
        params
        |> Map.delete("projects")
        |> Map.delete("user_teams")

      authorize_team_editor(conn, team.id, fn ->
        case UpdateTeam.call(id, update_params, user) do
          {:ok, team} ->
            conn
            |> put_flash(:info, "Team updated successfully.")
            |> redirect(to: Routes.team_path(conn, :show, team))

          {:error, %Ecto.Changeset{} = changeset} ->
            team = GetTeam.call(id, user, preload: @preload)

            render(conn, "edit.html", changeset: changeset, team: team)
        end
      end)
    end)
  end

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "teams:delete", fn ->
      user = current_user(conn)
      team = GetTeam.call!(id, user)

      authorize_in_team(conn, team.id, fn ->
        {:ok, _team} = DeleteTeam.call(id, params, user)

        conn
        |> put_flash(:info, "Team deleted successfully.")
        |> redirect(to: Routes.team_path(conn, :index))
      end)
    end)
  end

  # Helpers

  defp get_event_templates(team_id, user) do
    params = %{
      filters: %{
        active: true,
        team_id: team_id
      },
      preload: [:team]
    }

    ListEventTemplates.call(params, user)
  end

  defp get_projects(team_id, user) do
    params = %{
      filters: %{
        active: true,
        team_id: team_id
      },
      preload: [:team]
    }

    ListProjects.call(params, user)
  end

  defp get_user_teams(team_id, user) do
    params = %{
      filters: %{
        team_id: team_id
      },
      preload: [:team, :user]
    }

    ListUserTeams.call(params, user)
  end

  defp get_create_params(params, user) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put("user_teams", [
      %{
        type: "admin",
        created_by_id: user.id,
        user_id: user.id
      }
    ])
  end
end
