defmodule ArtemisWeb.RecognitionControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all recognitions", %{conn: conn} do
      conn = get(conn, Routes.recognition_path(conn, :index))
      assert html_response(conn, 200) =~ "Recognitions"
    end
  end

  describe "new recognition" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.recognition_path(conn, :new))
      assert html_response(conn, 200) =~ "New Recognition"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows recognition", %{conn: conn, record: record} do
      conn = get(conn, Routes.recognition_path(conn, :show, record))
      assert html_response(conn, 200) =~ record.description
    end
  end

  describe "edit recognition" do
    setup [:create_record]

    test "renders form for editing chosen recognition", %{conn: conn, record: record} do
      conn = get(conn, Routes.recognition_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Recognition"
    end
  end

  describe "delete recognition" do
    setup [:create_record]

    test "deletes chosen recognition", %{conn: conn, record: record} do
      conn = delete(conn, Routes.recognition_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.recognition_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.recognition_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:recognition)

    {:ok, record: record}
  end
end
