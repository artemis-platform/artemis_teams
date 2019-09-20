defmodule ArtemisWeb.EventTemplateControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  alias Artemis.EventTemplate

  @create_attrs %{active: "true", name: "Test Name", type: EventTemplate.allowed_types() |> Enum.at(0)}
  @update_attrs %{type: EventTemplate.allowed_types() |> Enum.at(0)}
  @invalid_attrs %{type: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all event template", %{conn: conn} do
      team = insert(:team)
      conn = get(conn, Routes.team_event_template_path(conn, :index, team))
      assert html_response(conn, 200) =~ "Event Templates"
    end
  end

  describe "new event template" do
    test "renders new form", %{conn: conn} do
      team = insert(:team)
      conn = get(conn, Routes.team_event_template_path(conn, :new, team))
      assert html_response(conn, 200) =~ "New Event Template"
    end
  end

  describe "create event template" do
    test "redirects to index when data is valid", %{conn: conn} do
      team = insert(:team)
      params = Map.put(@create_attrs, :team_id, team.id)

      conn = post(conn, Routes.team_event_template_path(conn, :create, team), event_template: params)
      assert redirected_to(conn) == Routes.team_event_template_path(conn, :index, team)

      conn = get(conn, Routes.team_event_template_path(conn, :index, team))
      assert html_response(conn, 200) =~ team.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      team = insert(:team)
      conn = post(conn, Routes.team_event_template_path(conn, :create, team), event_template: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event Template"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows event template", %{conn: conn, record: record} do
      conn = get(conn, Routes.team_event_template_path(conn, :show, record.team, record))
      assert html_response(conn, 200) =~ record.type
    end
  end

  describe "edit event template" do
    setup [:create_record]

    test "renders form for editing chosen event template", %{conn: conn, record: record} do
      conn = get(conn, Routes.team_event_template_path(conn, :edit, record.team, record))
      assert html_response(conn, 200) =~ "Edit Event Template"
    end
  end

  describe "update event template" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.team_event_template_path(conn, :update, record.team, record), event_template: @update_attrs)
      assert redirected_to(conn) == Routes.team_event_template_path(conn, :index, record.team)

      conn = get(conn, Routes.team_event_template_path(conn, :index, record.team))
      assert html_response(conn, 200) =~ @update_attrs.type
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.team_event_template_path(conn, :update, record.team, record), event_template: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit"
    end
  end

  describe "delete event template" do
    setup [:create_record]

    test "deletes chosen event template", %{conn: conn, record: record} do
      conn = delete(conn, Routes.team_event_template_path(conn, :delete, record.team, record))
      assert redirected_to(conn) == Routes.team_event_template_path(conn, :index, record.team)

      assert_error_sent 404, fn ->
        get(conn, Routes.team_event_template_path(conn, :show, record.team, record))
      end
    end
  end

  defp create_record(_) do
    team = insert(:team)
    record = insert(:event_template, team: team)

    {:ok, record: record}
  end
end
