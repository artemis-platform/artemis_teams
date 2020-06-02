defmodule ArtemisWeb.EventReportControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  setup %{conn: conn} do
    event_template = insert(:event_template)

    insert(:user_team, type: "admin", team: event_template.team, user: Mock.system_user())

    {:ok, conn: sign_in(conn), event_template: event_template}
  end

  describe "index" do
    test "lists all event reports", %{conn: conn, event_template: event_template} do
      conn = get(conn, Routes.event_report_path(conn, :index, event_template))
      assert html_response(conn, 200) =~ "Reports"
    end
  end
end
