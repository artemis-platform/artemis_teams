defmodule ArtemisWeb.RecognitionController do
  use ArtemisWeb, :controller

  use ArtemisWeb.Controller.CommentsShow,
    path: &Routes.recognition_path/3,
    permission: "recognitions:show",
    resource_getter: &Artemis.GetRecognition.call!/2,
    resource_id_key: "recognition_id",
    resource_type: "Recognition"

  alias Artemis.DeleteRecognition
  alias Artemis.GetRecognition
  alias Artemis.ListRecognitions

  def index(conn, params) do
    authorize(conn, "recognitions:list", fn ->
      user = current_user(conn)
      recognition_layout = Map.get(params, "layout", "full")
      recognitions = get_recognitions(params, user)

      assigns = [
        recognition_layout: recognition_layout,
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

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "recognitions:delete", fn ->
      {:ok, _recognition} = DeleteRecognition.call(id, params, current_user(conn))

      conn
      |> put_flash(:info, "Recognition deleted successfully.")
      |> redirect(to: Routes.recognition_path(conn, :index))
    end)
  end

  # Helpers

  defp get_recognitions(params, user) do
    if Map.get(params, "layout") == "compact" do
      params =
        params
        |> Map.put(:paginate, true)
        |> Map.put(:preload, [:created_by, :users])

      ListRecognitions.call(params, user)
    end
  end
end
