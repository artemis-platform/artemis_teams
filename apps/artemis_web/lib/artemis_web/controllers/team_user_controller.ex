defmodule ArtemisWeb.TeamUserController do
  use ArtemisWeb, :controller

  alias Artemis.CreateTeamUser
  alias Artemis.DeleteTeamUser
  alias Artemis.GetTeamUser
  alias Artemis.GetTeam
  alias Artemis.ListTeamUsers
  alias Artemis.ListUsers
  alias Artemis.TeamUser
  alias Artemis.UpdateTeamUser

  @preload []

  def index(conn, params) do
    authorize(conn, "team-users:list", fn ->
      user = current_user(conn)
      team = get_team!(params, user)
      params = Map.put(params, :paginate, true)
      team_users = ListTeamUsers.call(params, user)

      render(conn, "index.html", team: team, team_users: team_users)
    end)
  end

  def new(conn, params) do
    authorize(conn, "team-users:create", fn ->
      user = current_user(conn)
      team = get_team!(params, user)
      team_user = %TeamUser{}
      users = ListUsers.call(user)
      changeset = TeamUser.changeset(team_user)

      render(conn, "new.html", changeset: changeset, team: team, team_user: team_user, users: users)
    end)
  end

  def create(conn, %{"team_user" => params, "team_id" => team_id}) do
    authorize(conn, "team-users:create", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      params = Map.put(params, "team_id", team_id)

      case CreateTeamUser.call(params, user) do
        {:ok, _team_user} ->

          conn
          |> put_flash(:info, "Team member created successfully.")
          |> redirect(to: Routes.team_user_path(conn, :index, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          team_user = %TeamUser{}
          users = ListUsers.call(user)

          render(conn, "new.html", changeset: changeset, team: team, team_user: team_user, users: users)
      end
    end)
  end

  def show(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "team-users:show", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      team_user = GetTeamUser.call!(id, user)

      render(conn, "show.html", team: team, team_user: team_user)
    end)
  end

  def edit(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "team-users:update", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      team_user = GetTeamUser.call(id, user, preload: @preload)
      users = ListUsers.call(user)
      changeset = TeamUser.changeset(team_user)

      render(conn, "edit.html", changeset: changeset, team: team, team_user: team_user, users: users)
    end)
  end

  def update(conn, %{"id" => id, "team_user" => params, "team_id" => team_id}) do
    authorize(conn, "team-users:update", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      params = Map.put(params, "team_id", team_id)

      case UpdateTeamUser.call(id, params, user) do
        {:ok, _team_user} ->
          conn
          |> put_flash(:info, "Team member updated successfully.")
          |> redirect(to: Routes.team_user_path(conn, :index, team))

        {:error, %Ecto.Changeset{} = changeset} ->
          team_user = GetTeamUser.call(id, user, preload: @preload)
          users = ListUsers.call(user)

          render(conn, "edit.html", changeset: changeset, team: team, team_user: team_user, users: users)
      end
    end)
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "team-users:delete", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)

      {:ok, _team_user} = DeleteTeamUser.call(id, user)

      conn
      |> put_flash(:info, "Team user removed successfully.")
      |> redirect(to: Routes.team_user_path(conn, :index, team))
    end)
  end

  # Helpers

  defp get_team!(%{"team_id" => team_id}, user), do: get_team!(team_id, user)
  defp get_team!(id, user), do: GetTeam.call!(id, user)
end
