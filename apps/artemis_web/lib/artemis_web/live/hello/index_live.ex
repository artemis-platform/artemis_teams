defmodule ArtemisWeb.HelloIndexLive do
  use ArtemisWeb.LiveView

  import ArtemisWeb.Guardian.Helpers

  # TODO: move into helper
  # defp current_user(%{"guardian_default_token" => token}) do
  #   Guardian.resource_from_token(ArtemisWeb.Guardian, token)
  # end

  # LiveView Callbacks

  @impl true
  def mount(params, session, socket) do
    # IO.inspect socket
    # IO.inspect socket.private
    # IO.inspect socket.endpoint
    # IO.inspect session
    # IO.inspect Guardian.resource_from_token(ArtemisWeb.Guardian, session["guardian_default_token"])
    # IO.inspect session

    user = current_user(session)

    # user = Map.get(session, "user")
    # broadcast_topic = Artemis.Event.get_broadcast_topic()

    assigns =
      socket
      |> assign(:data, :loading)
      |> assign(:user, user)

    # if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

    # :ok = ArtemisPubSub.subscribe(broadcast_topic)

    {:ok, assigns}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign(socket, :url, url)}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.HelloView, "index.html", assigns)
  end
end
