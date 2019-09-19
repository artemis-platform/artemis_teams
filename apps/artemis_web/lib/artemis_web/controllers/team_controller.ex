defmodule ArtemisWeb.TeamController do
  use ArtemisWeb, :controller

  alias Artemis.CreateTeam
  alias Artemis.CreateTeamUser
  alias Artemis.Team
  alias Artemis.DeleteTeam
  alias Artemis.GetTeam
  alias Artemis.ListTeams
  alias Artemis.ListTeamUsers
  alias Artemis.UpdateTeam

  @preload []
  @team_user_type_on_create "admin"

  def index(conn, params) do
    authorize(conn, "teams:list", fn ->
      user = current_user(conn)

      teams =
        params
        |> Map.put(:paginate, true)
        |> ListTeams.call(user)

      my_teams =
        params
        |> Map.put(:filters, %{user_id: user.id})
        |> ListTeams.call(user)

      assigns = [
        my_teams: my_teams,
        teams: teams,
        user: user
      ]

      render(conn, "index.html", assigns)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "teams:create", fn ->
      team = %Team{active: true}
      changeset = Team.changeset(team)

      render(conn, "new.html", changeset: changeset, team: team)
    end)
  end

  def create(conn, %{"team" => params}) do
    authorize(conn, "teams:create", fn ->
      user = current_user(conn)

      case CreateTeam.call(params, user) do
        {:ok, team} ->
          team_user_params = %{
            team_id: team.id,
            type: @team_user_type_on_create,
            user_id: user.id
          }

          {:ok, _} = CreateTeamUser.call(team_user_params, user)

          conn
          |> put_flash(:info, "Team created successfully.")
          |> redirect(to: Routes.team_path(conn, :show, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          team = %Team{active: true}

          render(conn, "new.html", changeset: changeset, team: team)
      end
    end)
  end

  def show(conn, %{"id" => id} = params) do
    authorize(conn, "teams:show", fn ->
      user = current_user(conn)
      team = GetTeam.call!(id, user)

      team_users =
        params
        |> Map.delete("id")
        |> Map.put(:paginate, true)
        |> Map.put(:filters, %{team_id: team.id})
        |> ListTeamUsers.call(user)

      render(conn, "show.html", team: team, team_users: team_users)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "teams:update", fn ->
      team = GetTeam.call(id, current_user(conn), preload: @preload)
      changeset = Team.changeset(team)

      render(conn, "edit.html", changeset: changeset, team: team)
    end)
  end

  def update(conn, %{"id" => id, "team" => params}) do
    authorize(conn, "teams:update", fn ->
      case UpdateTeam.call(id, params, current_user(conn)) do
        {:ok, team} ->
          conn
          |> put_flash(:info, "Team updated successfully.")
          |> redirect(to: Routes.team_path(conn, :show, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          team = GetTeam.call(id, current_user(conn), preload: @preload)

          render(conn, "edit.html", changeset: changeset, team: team)
      end
    end)
  end

  def delete(conn, %{"id" => id}) do
    authorize(conn, "teams:delete", fn ->
      {:ok, _team} = DeleteTeam.call(id, current_user(conn))

      conn
      |> put_flash(:info, "Team deleted successfully.")
      |> redirect(to: Routes.team_path(conn, :index))
    end)
  end
end
