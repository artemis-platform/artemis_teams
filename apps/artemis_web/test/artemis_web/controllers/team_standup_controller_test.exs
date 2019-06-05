defmodule ArtemisWeb.TeamStandupControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all team standups", %{conn: conn} do
      team = insert(:team)
      conn = get(conn, Routes.team_standup_path(conn, :index, team))
      assert html_response(conn, 200) =~ "Team Standups"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows team standup", %{conn: conn, record: record} do
      conn = get(conn, Routes.team_standup_path(conn, :show, record.team, Date.to_string(record.date)))
      assert html_response(conn, 200) =~ String.slice(record.blockers, 0..10)
    end
  end

  defp create_record(_) do
    record = insert(:standup)

    {:ok, record: record}
  end
end
