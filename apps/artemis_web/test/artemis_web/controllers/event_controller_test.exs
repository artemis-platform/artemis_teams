defmodule ArtemisWeb.EventControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all event_templates", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :index))
      assert html_response(conn, 200) =~ "Events"
    end
  end

  describe "new event_template" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :new))
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "create event_template" do
    test "redirects to show when data is valid", %{conn: conn} do
      team = insert(:team)

      insert(:user_team, type: "admin", team: team, user: Mock.system_user())

      schedule_params = %{
        rule_01: %{
          days: [0, 2, 3],
          time: "9:00"
        }
      }

      params =
        :event_template
        |> params_for(team: team)
        |> Map.put(:schedule, schedule_params)

      conn = post(conn, Routes.event_path(conn, :create), event_template: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_path(conn, :show, id)

      conn = get(conn, Routes.event_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Title"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event_template: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows event_template", %{conn: conn, record: record} do
      conn = get(conn, Routes.event_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Title"
    end
  end

  describe "edit event_template" do
    setup [:create_record]

    test "renders form for editing chosen event_template", %{conn: conn, record: record} do
      conn = get(conn, Routes.event_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Save"
    end
  end

  describe "update event_template" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      schedule_params = %{
        rule_01: %{
          days: [0, 2, 3],
          time: "9:00"
        }
      }

      params = Map.merge(@update_attrs, %{schedule: schedule_params})

      conn = put(conn, Routes.event_path(conn, :update, record), event_template: params)
      assert redirected_to(conn) == Routes.event_path(conn, :show, record)

      conn = get(conn, Routes.event_path(conn, :show, record))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.event_path(conn, :update, record), event_template: @invalid_attrs)
      assert html_response(conn, 200) =~ "Error"
    end
  end

  describe "delete event_template" do
    setup [:create_record]

    test "deletes chosen event_template", %{conn: conn, record: record} do
      conn = delete(conn, Routes.event_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.event_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:event_template)

    insert(:user_team, type: "admin", team: record.team, user: Mock.system_user())

    {:ok, record: record}
  end
end
