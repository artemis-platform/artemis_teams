defmodule ArtemisWeb.RecognitionControllerLive do
  use ArtemisWeb.LiveView
  use ArtemisWeb.LiveController

  import ArtemisWeb.Guardian.Helpers

  # LiveView Controller

  def live_action(:show, socket, params) do
    live_authorize(socket, "recognitions:show", fn ->
      user = socket.assigns.user
      recognition = get_recognition(params, user)

      assigns = [
        data: nil,
        recognition: recognition,
        status: :loading
      ]

      # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

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

      # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

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

      # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

      {:ok, assign(socket, assigns)}
    end)
  end

  # Helpers

  defp get_recognition(params, user) do
    recognition_id = Map.get(params, "recognition_id") || Map.get(params, "id")

    Artemis.GetRecognition.call(recognition_id, user)
  end
end
