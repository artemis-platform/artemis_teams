defmodule ArtemisWeb.RecognitionShowLive do
  use ArtemisWeb.LiveView
  use ArtemisWeb.LiveController

  alias Artemis.DeleteRecognition
  alias Artemis.GetRecognition

  # LiveView Controller

  def live_action(:new, socket, _params) do
    live_authorize(socket, "recognitions:create", fn ->
      {:ok, socket}
    end)
  end

  def live_action(:show, socket, params) do
    live_authorize(socket, "recognitions:show", fn ->
      user = socket.assigns.user
      recognition = get_recognition(params, user)

      assigns = [
        data: nil,
        recognition: recognition,
        status: :loading
      ]

      {:ok, assign(socket, assigns)}
    end)
  end

  def live_action(:edit, socket, params) do
    live_authorize(socket, "recognitions:update", fn ->
      user = socket.assigns.user
      recognition = get_recognition(params, user)

      assigns = [
        data: nil,
        recognition: recognition,
        status: :loading
      ]

      {:ok, assign(socket, assigns)}
    end)
  end

  def live_action(:edit_comment, socket, params) do
    live_authorize(socket, "recognitions:show", fn ->
      user = socket.assigns.user
      recognition = get_recognition(params, user)

      assigns = [
        data: nil,
        recognition: recognition,
        status: :loading
      ]

      {:ok, assign(socket, assigns)}
    end)
  end

  def live_action(:delete, socket, params) do
    live_authorize(socket, "recognitions:delete", fn ->
      user = socket.assigns.user
      id = Map.get(params, "id")

      {:ok, _recognition} = DeleteRecognition.call(id, user)

      socket =
        socket
        |> put_flash(:info, "Recognition deleted successfully.")
        |> redirect(to: Routes.recognition_path(socket, :index))

      {:ok, socket}
    end)
  end

  # Helpers

  defp get_recognition(params, user) do
    recognition_id = Map.get(params, "recognition_id") || Map.get(params, "id")

    GetRecognition.call!(recognition_id, user)
  end
end
