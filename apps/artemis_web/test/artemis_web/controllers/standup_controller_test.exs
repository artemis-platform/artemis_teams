defmodule ArtemisWeb.StandupControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @create_attrs %{date: "2020-01-01", blockers: "Test Blockers"}
  @update_attrs %{date: "2020-01-01", blockers: "Updated Blockers"}
  @invalid_attrs %{date: nil, blockers: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all standups", %{conn: conn} do
      team = insert(:team)
      conn = get(conn, Routes.team_standup_path(conn, :index, team))
      assert html_response(conn, 200) =~ "Standups"
    end
  end

  describe "new standup" do
    test "renders new form", %{conn: conn} do
      team = insert(:team)
      conn = get(conn, Routes.team_standup_path(conn, :new, team))
      assert html_response(conn, 200) =~ "New Standup"
    end
  end

  describe "create standup" do
    test "redirects to show when data is valid", %{conn: conn} do
      team = insert(:team)
      conn = post(conn, Routes.team_standup_path(conn, :create, team), standup: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.team_standup_path(conn, :show, team, id)

      conn = get(conn, Routes.team_standup_path(conn, :show, team, id))
      assert html_response(conn, 200) =~ "Test Blockers"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      team = insert(:team)
      conn = post(conn, Routes.team_standup_path(conn, :create, team), standup: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Standup"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows standup", %{conn: conn, record: record} do
      conn = get(conn, Routes.team_standup_path(conn, :show, record.team, record))
      assert html_response(conn, 200) =~ record.blockers
    end
  end

  describe "edit standup" do
    setup [:create_record]

    test "renders form for editing chosen standup", %{conn: conn, record: record} do
      conn = get(conn, Routes.team_standup_path(conn, :edit, record.team, record))
      assert html_response(conn, 200) =~ "Edit Standup"
    end
  end

  describe "update standup" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.team_standup_path(conn, :update, record.team, record), standup: @update_attrs)
      assert redirected_to(conn) == Routes.team_standup_path(conn, :show, record.team, record)

      conn = get(conn, Routes.team_standup_path(conn, :show, record.team, record))
      assert html_response(conn, 200) =~ "Updated Blockers"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.team_standup_path(conn, :update, record.team, record), standup: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Standup"
    end
  end

  describe "delete standup" do
    setup [:create_record]

    test "deletes chosen standup", %{conn: conn, record: record} do
      conn = delete(conn, Routes.team_standup_path(conn, :delete, record.team, record))
      assert redirected_to(conn) == Routes.team_standup_path(conn, :index, record.team)

      assert_error_sent 404, fn ->
        get(conn, Routes.team_standup_path(conn, :show, record.team, record))
      end
    end
  end

  defp create_record(_) do
    team = insert(:team)
    record = insert(:standup, team: team)

    {:ok, record: record}
  end
end
