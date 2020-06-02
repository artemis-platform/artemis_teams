defmodule ArtemisWeb.RecognitionTotalsLive do
  use ArtemisWeb.LiveView

  alias Artemis.ListRecognitions

  # LiveView Callbacks

  @impl true
  def mount(_params, session, socket) do
    user = Map.get(session, "user")
    broadcast_topic = Artemis.Event.get_broadcast_topic()

    assigns =
      socket
      |> assign(:totals, :loading)
      |> assign(:user, user)

    if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

    :ok = ArtemisPubSub.subscribe(broadcast_topic)

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "_totals.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_info(:async_load_data, socket) do
    {:noreply, load_totals(socket)}
  end

  def handle_info(%{event: "recognition:created", payload: _payload}, socket) do
    {:noreply, load_totals(socket)}
  end

  def handle_info(%{event: "recognition:updated", payload: _payload}, socket) do
    {:noreply, load_totals(socket)}
  end

  def handle_info(%{event: "recognition:deleted", payload: _payload}, socket) do
    {:noreply, load_totals(socket)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  # Helpers

  defp load_totals(socket) do
    user = socket.assigns.user

    params = %{
      count: true
    }

    all =
      params
      |> ListRecognitions.call(user)
      |> hd()
      |> Map.get(:count)

    # From User

    params = %{
      count: true,
      filters: %{
        created_by_id: user.id
      }
    }

    from_user =
      params
      |> ListRecognitions.call(user)
      |> hd()
      |> Map.get(:count)

    # To User

    params = %{
      count: true,
      filters: %{
        user_id: user.id
      }
    }

    to_user =
      params
      |> ListRecognitions.call(user)
      |> hd()
      |> Map.get(:count)

    # Combined

    totals = %{
      all: all,
      from_user: from_user,
      to_user: to_user
    }

    assign(socket, :totals, totals)
  end
end
