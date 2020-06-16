defmodule ArtemisWeb.RecognitionControllerTest do
  use ArtemisWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all recognitions", %{conn: conn} do
      conn = get(conn, Routes.recognition_path(conn, :index))
      assert html_response(conn, 200) =~ "Recognitions"
    end
  end
end
