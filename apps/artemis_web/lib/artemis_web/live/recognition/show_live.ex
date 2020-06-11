defmodule ArtemisWeb.RecognitionShowLive do
  use ArtemisWeb.LiveView

  import ArtemisWeb.Guardian.Helpers

  # LiveView Callbacks

  @impl true
  def mount(params, session, socket) do
    # IO.inspect socket
    # IO.inspect socket.private
    # IO.inspect socket.endpoint
    # IO.inspect session
    # IO.inspect Guardian.resource_from_token(ArtemisWeb.Guardian, session["guardian_default_token"])
    # IO.inspect session

    # TODO: add show page authorization check

    user = current_user(session)
    recognition_id = Map.get(params, "recognition_id") || Map.get(params, "id")
    recognition = Artemis.GetRecognition.call(recognition_id, user)

    # broadcast_topic = Artemis.Event.get_broadcast_topic()

    assigns =
      socket
      |> assign(:data, nil)
      |> assign(:params, params)
      |> assign(:recognition, recognition)
      |> assign(:status, :loading)
      |> assign(:user, user)

    # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

    # :ok = ArtemisPubSub.subscribe(broadcast_topic)

    {:ok, assigns}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign(socket, path: URI.parse(url).path, url: url)}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "#{assigns.live_action}.html", assigns)
  end
end
