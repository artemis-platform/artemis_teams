defmodule ArtemisWeb.EventIntegrationControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{integration_type: nil}

  setup %{conn: conn} do
    event_template = insert(:event_template)

    {:ok, conn: sign_in(conn), event_template: event_template}
  end

  describe "index" do
    test "lists all event integrations", %{conn: conn, event_template: event_template} do
      conn = get(conn, Routes.event_integration_path(conn, :index, event_template))
      assert html_response(conn, 200) =~ "Integrations"
    end
  end

  describe "new event_integration" do
    test "renders new form", %{conn: conn, event_template: event_template} do
      conn = get(conn, Routes.event_integration_path(conn, :new, event_template))
      assert html_response(conn, 200) =~ "New Event Integration"
    end
  end

  describe "create event_integration" do
    test "redirects to show when data is valid", %{conn: conn, event_template: event_template} do
      params = params_for(:event_integration, event_template: event_template)

      conn = post(conn, Routes.event_integration_path(conn, :create, event_template), event_integration: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_template)

      conn = get(conn, Routes.event_path(conn, :show, event_template))
      assert html_response(conn, 200) =~ "Details"
    end

    test "renders errors when data is invalid", %{conn: conn, event_template: event_template} do
      conn = post(conn, Routes.event_integration_path(conn, :create, event_template), event_integration: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event Integration"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows event_integration", %{conn: conn, event_template: event_template, record: record} do
      conn = get(conn, Routes.event_integration_path(conn, :show, event_template, record))
      assert html_response(conn, 200) =~ "Name"
    end
  end

  describe "edit event_integration" do
    setup [:create_record]

    test "renders form for editing chosen event_integration", %{
      conn: conn,
      event_template: event_template,
      record: record
    } do
      conn = get(conn, Routes.event_integration_path(conn, :edit, event_template, record))
      assert html_response(conn, 200) =~ "Save"
    end
  end

  describe "update event_integration" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, event_template: event_template, record: record} do
      conn =
        put(conn, Routes.event_integration_path(conn, :update, event_template, record), event_integration: @update_attrs)

      assert redirected_to(conn) == Routes.event_path(conn, :show, event_template)

      conn = get(conn, Routes.event_path(conn, :show, event_template))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, event_template: event_template, record: record} do
      conn =
        put(conn, Routes.event_integration_path(conn, :update, event_template, record),
          event_integration: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Save"
    end
  end

  describe "delete event_integration" do
    setup [:create_record]

    test "deletes chosen event_integration", %{conn: conn, event_template: event_template, record: record} do
      conn = delete(conn, Routes.event_integration_path(conn, :delete, event_template, record))
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_template)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_integration_path(conn, :show, event_template, record))
      end
    end
  end

  defp create_record(params) do
    record = insert(:event_integration, event_template: params[:event_template])

    {:ok, record: record}
  end
end
