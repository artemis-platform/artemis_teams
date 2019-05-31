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
      conn = get(conn, Routes.standup_path(conn, :index))
      assert html_response(conn, 200) =~ "Standups"
    end
  end

  describe "new standup" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.standup_path(conn, :new))
      assert html_response(conn, 200) =~ "New Standup"
    end
  end

  describe "create standup" do
    test "redirects to show when data is valid", %{conn: conn} do
      team = insert(:team)
      user = insert(:user)
      params =
        @create_attrs
        |> Map.put(:team_id, team.id)
        |> Map.put(:user_id, user.id)

      conn = post(conn, Routes.standup_path(conn, :create), standup: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.standup_path(conn, :show, id)

      conn = get(conn, Routes.standup_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Test Blockers"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.standup_path(conn, :create), standup: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Standup"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows standup", %{conn: conn, record: record} do
      conn = get(conn, Routes.standup_path(conn, :show, record))
      assert html_response(conn, 200) =~ record.blockers
    end
  end

  describe "edit standup" do
    setup [:create_record]

    test "renders form for editing chosen standup", %{conn: conn, record: record} do
      conn = get(conn, Routes.standup_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Standup"
    end
  end

  describe "update standup" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.standup_path(conn, :update, record), standup: @update_attrs)
      assert redirected_to(conn) == Routes.standup_path(conn, :show, record)

      conn = get(conn, Routes.standup_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Updated Blockers"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.standup_path(conn, :update, record), standup: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Standup"
    end
  end

  describe "delete standup" do
    setup [:create_record]

    test "deletes chosen standup", %{conn: conn, record: record} do
      conn = delete(conn, Routes.standup_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.standup_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.standup_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:standup)

    {:ok, record: record}
  end
end
