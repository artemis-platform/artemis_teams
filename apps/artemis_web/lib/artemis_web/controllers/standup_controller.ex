defmodule ArtemisWeb.StandupController do
  use ArtemisWeb, :controller

  alias Artemis.CreateStandup
  alias Artemis.DeleteStandup
  alias Artemis.GetStandup
  alias Artemis.GetTeam
  alias Artemis.ListStandups
  alias Artemis.Standup
  alias Artemis.UpdateStandup

  @preload []

  def index(conn, params) do
    authorize(conn, "standups:list", fn ->
      user = current_user(conn)
      team = get_team!(params, user)
      params = Map.put(params, :paginate, true)
      standups = ListStandups.call(params, user)

      render(conn, "index.html", standups: standups, team: team)
    end)
  end

  def new(conn, params) do
    authorize(conn, "standups:create", fn ->
      user = current_user(conn)
      team = get_team!(params, user)
      standup = %Standup{}
      changeset = Standup.changeset(standup)

      render(conn, "new.html", changeset: changeset, standup: standup, team: team)
    end)
  end

  def create(conn, %{"standup" => params, "team_id" => team_id}) do
    authorize(conn, "standups:create", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      params =
        params
        |> Map.put("team_id", team_id)
        |> Map.put("user_id", user.id)

      case CreateStandup.call(params, user) do
        {:ok, standup} ->

          conn
          |> put_flash(:info, "Standup created successfully.")
          |> redirect(to: Routes.team_standup_path(conn, :show, team, standup))

        {:error, %Ecto.Changeset{} = changeset} ->
          standup = %Standup{}

          render(conn, "new.html", changeset: changeset, standup: standup, team: team)
      end
    end)
  end

  def show(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "standups:show", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      standup = GetStandup.call!(id, user)

      render(conn, "show.html", standup: standup, team: team)
    end)
  end

  def edit(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "standups:update", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      standup = GetStandup.call(id, user, preload: @preload)
      changeset = Standup.changeset(standup)

      render(conn, "edit.html", changeset: changeset, standup: standup, team: team)
    end)
  end

  def update(conn, %{"id" => id, "standup" => params, "team_id" => team_id}) do
    authorize(conn, "standups:update", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)

      params =
        params
        |> Map.put("team_id", team_id)
        |> Map.put("user_id", user.id)

      case UpdateStandup.call(id, params, user) do
        {:ok, standup} ->
          conn
          |> put_flash(:info, "Standup updated successfully.")
          |> redirect(to: Routes.team_standup_path(conn, :show, team, standup))

        {:error, %Ecto.Changeset{} = changeset} ->
          standup = GetStandup.call(id, user, preload: @preload)

          render(conn, "edit.html", changeset: changeset, standup: standup, team: team)
      end
    end)
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "standups:delete", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)

      {:ok, _standup} = DeleteStandup.call(id, user)

      conn
      |> put_flash(:info, "Standup deleted successfully.")
      |> redirect(to: Routes.team_standup_path(conn, :index, team))
    end)
  end

  # Helpers

  defp get_team!(%{"team_id" => team_id}, user), do: get_team!(team_id, user)
  defp get_team!(id, user), do: GetTeam.call!(id, user)
end
