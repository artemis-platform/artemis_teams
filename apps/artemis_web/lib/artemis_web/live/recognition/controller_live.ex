defmodule ArtemisWeb.RecognitionControllerLive do
  use ArtemisWeb.LiveView
  use ArtemisWeb.LiveController

  import ArtemisWeb.Guardian.Helpers

  # LiveView Controller

  def live_action(:show, socket, params) do
    live_authorize(socket, "recognitions:show", fn ->
      user = socket.assigns.user
      recognition_id = Map.get(params, "recognition_id") || Map.get(params, "id")
      recognition = Artemis.GetRecognition.call(recognition_id, user)

      socket =
        socket
        |> assign(:data, nil)
        |> assign(:recognition, recognition)
        |> assign(:status, :loading)

      # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

      {:ok, socket}
    end)
  end

  def live_action(:edit_comment, socket, params) do
    live_authorize(socket, "recognitions:show", fn ->
      user = socket.assigns.user
      recognition_id = Map.get(params, "recognition_id") || Map.get(params, "id")
      recognition = Artemis.GetRecognition.call(recognition_id, user)

      socket =
        socket
        |> assign(:data, nil)
        |> assign(:recognition, recognition)
        |> assign(:status, :loading)

      # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

      {:ok, socket}
    end)
  end
end
