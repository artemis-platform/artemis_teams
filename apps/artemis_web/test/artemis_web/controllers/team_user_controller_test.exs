defmodule ArtemisWeb.TeamUserControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  alias Artemis.TeamUser

  @create_attrs %{type: TeamUser.allowed_types() |> Enum.at(0)}
  @update_attrs %{type: TeamUser.allowed_types() |> Enum.at(1)}
  @invalid_attrs %{type: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all team user", %{conn: conn} do
      team = insert(:team)
      conn = get(conn, Routes.team_user_path(conn, :index, team))
      assert html_response(conn, 200) =~ "Team Users"
    end
  end

  describe "new team user" do
    test "renders new form", %{conn: conn} do
      team = insert(:team)
      conn = get(conn, Routes.team_user_path(conn, :new, team))
      assert html_response(conn, 200) =~ "New Team User"
    end
  end

  describe "create team user" do
    test "redirects to index when data is valid", %{conn: conn} do
      team = insert(:team)
      user = insert(:user)
      params =
        @create_attrs
        |> Map.put(:team_id, team.id)
        |> Map.put(:user_id, user.id)

      conn = post(conn, Routes.team_user_path(conn, :create, team), team_user: params)
      assert redirected_to(conn) == Routes.team_user_path(conn, :index, team)

      conn = get(conn, Routes.team_user_path(conn, :index, team))
      assert html_response(conn, 200) =~ user.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      team = insert(:team)
      conn = post(conn, Routes.team_user_path(conn, :create, team), team_user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Team User"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows team user", %{conn: conn, record: record} do
      conn = get(conn, Routes.team_user_path(conn, :show, record))
      assert html_response(conn, 200) =~ record.type
    end
  end

  describe "edit team user" do
    setup [:create_record]

    test "renders form for editing chosen team user", %{conn: conn, record: record} do
      conn = get(conn, Routes.team_user_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Team User"
    end
  end

  describe "update team user" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.team_user_path(conn, :update, record), team_user: @update_attrs)
      assert redirected_to(conn) == Routes.team_user_path(conn, :index, record.team)

      conn = get(conn, Routes.team_user_path(conn, :index, record.team))
      assert html_response(conn, 200) =~ @update_attrs.type
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.team_user_path(conn, :update, record), team_user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit"
    end
  end

  describe "delete team user" do
    setup [:create_record]

    test "deletes chosen team user", %{conn: conn, record: record} do
      conn = delete(conn, Routes.team_user_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.team_user_path(conn, :index, record.team)

      assert_error_sent 404, fn ->
        get(conn, Routes.team_user_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    team = insert(:team)
    record = insert(:team_user, team: team)

    {:ok, record: record}
  end
end
