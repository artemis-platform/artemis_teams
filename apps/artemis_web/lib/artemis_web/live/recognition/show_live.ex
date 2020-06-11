defmodule ArtemisWeb.RecognitionShowLive do
  use ArtemisWeb.LiveView

  import ArtemisWeb.Guardian.Helpers

  # LiveView Callbacks

  @impl true
  def mount(params, session, socket) do
    socket
    |> default_assigns(params, session)
    |> call_controller_mount_live_action()
  end

  @impl true
  def handle_params(params, url, socket) do
    assigns = [
      live_params: params,
      path: URI.parse(url).path,
      url: url
    ]

    {:noreply, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "#{assigns.live_action}.html", assigns)
  end

  defp default_assigns(socket, params, session) do
    user = current_user(session)

    socket
    |> assign(:live_params, params)
    |> assign(:live_session, session)
    |> assign(:user, user)
  end

  defp call_controller_mount_live_action(socket) do
    live_action(socket.assigns.live_action, socket, socket.assigns.live_params)
  end

  # LiveView Controller Mount Actions

  def live_action(:show, socket, params) do
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
  end

  def live_action(:edit_comment, socket, params) do
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
  end
end
