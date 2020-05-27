defmodule ArtemisWeb.RecognitionController do
  use ArtemisWeb, :controller

  alias Artemis.DeleteRecognition
  alias Artemis.GetRecognition
  alias Artemis.ListRecognitions

  def index(conn, params) do
    authorize(conn, "recognitions:list", fn ->
      user = current_user(conn)

      params =
        params
        |> Map.put(:paginate, true)
        |> Map.put(:preload, [:created_by, :users])

      recognitions = ListRecognitions.call(params, user)

      assigns = [
        recognitions: recognitions
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "recognitions:create", fn ->
      render(conn, "new.html")
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "recognitions:show", fn ->
      recognition = GetRecognition.call!(id, current_user(conn), preload: [:created_by, :users])

      render(conn, "show.html", recognition: recognition)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "recognitions:update", fn ->
      recognition = GetRecognition.call!(id, current_user(conn), preload: [:users])

      render(conn, "edit.html", recognition: recognition)
    end)
  end

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "recognitions:delete", fn ->
      {:ok, _recognition} = DeleteRecognition.call(id, params, current_user(conn))

      conn
      |> put_flash(:info, "Recognition deleted successfully.")
      |> redirect(to: Routes.recognition_path(conn, :index))
    end)
  end
end
