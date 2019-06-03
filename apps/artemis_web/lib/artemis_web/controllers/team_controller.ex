defmodule ArtemisWeb.TeamController do
  use ArtemisWeb, :controller

  alias Artemis.CreateTeam
  alias Artemis.Team
  alias Artemis.DeleteTeam
  alias Artemis.GetTeam
  alias Artemis.GetUser
  alias Artemis.ListTeams
  alias Artemis.UpdateTeam

  @preload []

  def index(conn, params) do
    authorize(conn, "teams:list", fn ->
      user = current_user(conn)
      params = Map.put(params, :paginate, true)
      teams = ListTeams.call(params, user)
      my_teams = GetUser.call(user.id, current_user(conn), preload: [:teams]).teams

      render(conn, "index.html", my_teams: my_teams, teams: teams, user: user)
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
      case CreateTeam.call(params, current_user(conn)) do
        {:ok, team} ->
          conn
          |> put_flash(:info, "Team created successfully.")
          |> redirect(to: Routes.team_path(conn, :show, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          team = %Team{active: true}

          render(conn, "new.html", changeset: changeset, team: team)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "teams:show", fn ->
      team = GetTeam.call!(id, current_user(conn))

      render(conn, "show.html", team: team)
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
