defmodule ArtemisWeb.RecognitionShowLive do
  use ArtemisWeb.LiveView

  import ArtemisWeb.Guardian.Helpers

  # LiveView Callbacks

  @impl true
  def mount(params, session, socket) do
    socket
    |> default_assigns(params, session)
    |> call_controller_action()
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign(socket, path: URI.parse(url).path, url: url)}
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

  defp call_controller_action(socket) do
    action(socket.assigns.live_action, socket, socket.assigns.live_params)
  end

  # LiveView Controller Actions

  def action(:show, socket, params) do
    user = socket.assigns.user
    recognition_id = Map.get(params, "recognition_id") || Map.get(params, "id")
    recognition = Artemis.GetRecognition.call(recognition_id, user)

    # broadcast_topic = Artemis.Event.get_broadcast_topic()

    socket =
      socket
      |> assign(:data, nil)
      |> assign(:recognition, recognition)
      |> assign(:status, :loading)

    # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

    # :ok = ArtemisPubSub.subscribe(broadcast_topic)

    {:ok, socket}
  end
end
