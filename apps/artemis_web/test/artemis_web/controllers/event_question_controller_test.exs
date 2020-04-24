defmodule ArtemisWeb.EventQuestionControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  setup %{conn: conn} do
    event_template = insert(:event_template)

    {:ok, conn: sign_in(conn), event_template: event_template}
  end

  describe "index" do
    test "redirects to event template show", %{conn: conn, event_template: event_template} do
      conn = get(conn, Routes.event_question_path(conn, :index, event_template))
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_template)
    end
  end

  describe "new event_question" do
    test "renders new form", %{conn: conn, event_template: event_template} do
      conn = get(conn, Routes.event_question_path(conn, :new, event_template))
      assert html_response(conn, 200) =~ "New Event Question"
    end
  end

  describe "create event_question" do
    test "redirects to show when data is valid", %{conn: conn, event_template: event_template} do
      params = params_for(:event_question, event_template: event_template)

      conn = post(conn, Routes.event_question_path(conn, :create, event_template), event_question: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_template)

      conn = get(conn, Routes.event_path(conn, :show, event_template))
      assert html_response(conn, 200) =~ "Title"
    end

    test "renders errors when data is invalid", %{conn: conn, event_template: event_template} do
      conn = post(conn, Routes.event_question_path(conn, :create, event_template), event_question: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event Question"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows event_question", %{conn: conn, event_template: event_template, record: record} do
      conn = get(conn, Routes.event_question_path(conn, :show, event_template, record))
      assert html_response(conn, 200) =~ "Title"
    end
  end

  describe "edit event_question" do
    setup [:create_record]

    test "renders form for editing chosen event_question", %{conn: conn, event_template: event_template, record: record} do
      conn = get(conn, Routes.event_question_path(conn, :edit, event_template, record))
      assert html_response(conn, 200) =~ "Edit Event Question"
    end
  end

  describe "update event_question" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, event_template: event_template, record: record} do
      conn = put(conn, Routes.event_question_path(conn, :update, event_template, record), event_question: @update_attrs)
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_template)

      conn = get(conn, Routes.event_path(conn, :show, event_template))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, event_template: event_template, record: record} do
      conn =
        put(conn, Routes.event_question_path(conn, :update, event_template, record), event_question: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Event Question"
    end
  end

  describe "delete event_question" do
    setup [:create_record]

    test "deletes chosen event_question", %{conn: conn, event_template: event_template, record: record} do
      conn = delete(conn, Routes.event_question_path(conn, :delete, event_template, record))
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_template)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_question_path(conn, :show, event_template, record))
      end
    end
  end

  defp create_record(params) do
    record = insert(:event_question, event_template: params[:event_template])

    {:ok, record: record}
  end
end
