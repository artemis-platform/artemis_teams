defmodule ArtemisWeb.RecognitionControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @create_attrs %{name: "some name", slug: "test-slug"}
  @update_attrs %{name: "some updated name", slug: "test-slug"}
  @invalid_attrs %{name: nil, slug: nil}

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

  describe "create recognition" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.recognition_path(conn, :create), recognition: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.recognition_path(conn, :show, id)

      conn = get(conn, Routes.recognition_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.recognition_path(conn, :create), recognition: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Recognition"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows recognition", %{conn: conn, record: record} do
      conn = get(conn, Routes.recognition_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Name"
    end
  end

  describe "edit recognition" do
    setup [:create_record]

    test "renders form for editing chosen recognition", %{conn: conn, record: record} do
      conn = get(conn, Routes.recognition_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Recognition"
    end
  end

  describe "update recognition" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.recognition_path(conn, :update, record), recognition: @update_attrs)
      assert redirected_to(conn) == Routes.recognition_path(conn, :show, record)

      conn = get(conn, Routes.recognition_path(conn, :show, record))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.recognition_path(conn, :update, record), recognition: @invalid_attrs)
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
