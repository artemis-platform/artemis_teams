defmodule ArtemisWeb.RecognitionController do
  use ArtemisWeb, :controller

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
