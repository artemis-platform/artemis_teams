defmodule ArtemisWeb.StandupController do
  use ArtemisWeb, :controller

  alias Artemis.CreateStandup
  alias Artemis.DeleteStandup
  alias Artemis.GetStandup
  alias Artemis.GetUser
  alias Artemis.ListStandups
  alias Artemis.Standup
  alias Artemis.UpdateStandup

  @preload []

  def index(conn, params) do
    authorize(conn, "standups:list", fn ->
      user = current_user(conn)
      params = Map.put(params, :paginate, true)
      standups = ListStandups.call(params, user)

      render(conn, "index.html", standups: standups)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "standups:create", fn ->
      user = current_user(conn)
      standup = %Standup{}
      teams = get_teams!(user)
      changeset = Standup.changeset(standup)

      render(conn, "new.html", changeset: changeset, standup: standup, teams: teams)
    end)
  end

  def create(conn, %{"standup" => params}) do
    authorize(conn, "standups:create", fn ->
      user = current_user(conn)
      params = Map.put(params, "user_id", user.id)

      case CreateStandup.call(params, user) do
        {:ok, standup} ->

          conn
          |> put_flash(:info, "Standup created successfully.")
          |> redirect(to: Routes.standup_path(conn, :show, standup))

        {:error, %Ecto.Changeset{} = changeset} ->
          standup = %Standup{}
          teams = get_teams!(user)

          render(conn, "new.html", changeset: changeset, standup: standup, teams: teams)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "standups:show", fn ->
      user = current_user(conn)
      standup = GetStandup.call!(id, user)

      render(conn, "show.html", standup: standup)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "standups:update", fn ->
      user = current_user(conn)
      teams = get_teams!(user)
      standup = GetStandup.call(id, user, preload: @preload)
      changeset = Standup.changeset(standup)

      render(conn, "edit.html", changeset: changeset, standup: standup, teams: teams)
    end)
  end

  def update(conn, %{"id" => id, "standup" => params}) do
    authorize(conn, "standups:update", fn ->
      user = current_user(conn)
      params = Map.put(params, "user_id", user.id)

      case UpdateStandup.call(id, params, user) do
        {:ok, standup} ->
          conn
          |> put_flash(:info, "Standup updated successfully.")
          |> redirect(to: Routes.standup_path(conn, :show, standup))

        {:error, %Ecto.Changeset{} = changeset} ->
          standup = GetStandup.call(id, user, preload: @preload)
          teams = get_teams!(user)

          render(conn, "edit.html", changeset: changeset, standup: standup, teams: teams)
      end
    end)
  end

  def delete(conn, %{"id" => id}) do
    authorize(conn, "standups:delete", fn ->
      user = current_user(conn)

      {:ok, _standup} = DeleteStandup.call(id, user)

      conn
      |> put_flash(:info, "Standup deleted successfully.")
      |> redirect(to: Routes.standup_path(conn, :index))
    end)
  end

  # Helpers

  def get_teams!(user) do
    user
    |> Map.get(:id)
    |> GetUser.call!(user, preload: [:teams])
    |> Map.get(:teams)
  end
end
