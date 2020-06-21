defmodule ArtemisWeb.RecognitionControllerLiveTest do
  # use ArtemisWeb.ConnCase

  # import Artemis.Factories
  # import Phoenix.LiveViewTest

  # setup %{conn: conn} do
  #   {:ok, conn: sign_in(conn)}
  # end

  # describe "new recognition" do
  #   test "renders new form", %{conn: conn} do
  #     {:ok, _view, html} = live(conn, Routes.recognition_show_path(conn, :new))
  #     assert html =~ "New Recognition"
  #   end
  # end

  # describe "show" do
  #   setup [:create_record]

  #   test "shows recognition", %{conn: conn, record: record} do
  #     {:ok, _view, html} = live(conn, Routes.recognition_show_path(conn, :show, record))
  #     assert html =~ record.description
  #   end
  # end

  # describe "edit recognition" do
  #   setup [:create_record]

  #   test "renders form for editing chosen recognition", %{conn: conn, record: record} do
  #     {:ok, _view, html} = live(conn, Routes.recognition_show_path(conn, :edit, record))
  #     assert html =~ "Edit Recognition"
  #   end
  # end

  # describe "delete recognition" do
  #   setup [:create_record]

  #   test "deletes chosen recognition", %{conn: conn, record: record} do
  #     result = live(conn, Routes.recognition_show_path(conn, :delete, record))
  #     assert live_redirected_to(result) == Routes.recognition_path(conn, :index)

  #     assert_error_sent 404, fn ->
  #       {:ok, _view, _html} = live(conn, Routes.recognition_show_path(conn, :show, record))
  #     end
  #   end
  # end

  # defp create_record(_) do
  #   record = insert(:recognition)

  #   {:ok, record: record}
  # end
end
