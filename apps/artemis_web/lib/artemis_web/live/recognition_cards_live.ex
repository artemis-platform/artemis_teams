defmodule ArtemisWeb.RecognitionCardsLive do
  use ArtemisWeb.LiveView

  alias Artemis.ListComments

  # LiveView Callbacks

  @impl true
  def mount(_params, session, socket) do
    user = Map.get(session, "user")
    recognitions = Map.get(session, "recognitions")
    broadcast_topic = Artemis.Event.get_broadcast_topic()

    assigns =
      socket
      |> assign(:comments, :loading)
      |> assign(:recognitions, recognitions)
      |> assign(:user, user)

    if connected?(socket), do: Process.send_after(self(), :list_comments, 10)

    :ok = ArtemisPubSub.subscribe(broadcast_topic)

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "show/_cards.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_info(:list_comments, socket) do
    comments = list_comments(socket)

    {:noreply, assign(socket, :comments, comments)}
  end

  def handle_info(%{event: "comment:created", payload: payload}, socket) do
    comments = maybe_add_comment(socket, payload)

    {:noreply, assign(socket, :comments, comments)}
  end

  def handle_info(%{event: "comment:updated", payload: payload}, socket) do
    comments = maybe_update_comment(socket, payload)

    {:noreply, assign(socket, :comments, comments)}
  end

  def handle_info(%{event: "comment:deleted", payload: payload}, socket) do
    comments = maybe_delete_comment(socket, payload)

    {:noreply, assign(socket, :comments, comments)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  # Helpers - GenServer Callback Events

  defp list_comments(socket) do
    params = %{
      filters: %{
        resource_id: get_ids(socket),
        resource_type: "Recognition"
      }
    }

    ListComments.call(params, socket.assigns.user)
  end

  defp maybe_add_comment(socket, payload) do
    case resource_type_match?(payload) && resource_id_match?(socket, payload) do
      true -> [payload.data | socket.assigns.comments]
      false -> socket.assigns.comments
    end
  end

  defp maybe_update_comment(socket, payload) do
    case resource_type_match?(payload) && resource_id_match?(socket, payload) do
      true -> update_comment(socket.assigns.comments, payload.data)
      false -> socket.assigns.comments
    end
  end

  defp maybe_delete_comment(socket, payload) do
    case resource_type_match?(payload) && resource_id_match?(socket, payload) do
      true -> delete_comment(socket.assigns.comments, payload.data)
      false -> socket.assigns.comments
    end
  end

  # Helpers

  defp get_ids(socket) do
    socket.assigns
    |> Map.get(:recognitions)
    |> Enum.map(&Integer.to_string(&1.id))
  end

  defp resource_type_match?(payload), do: payload.data.resource_type == "Recognition"

  defp resource_id_match?(socket, payload) do
    Enum.member?(get_ids(socket), payload.data.resource_id)
  end

  defp update_comment(current, new) do
    Enum.map(current, fn item ->
      case item.id == new.id do
        true -> new
        false -> item
      end
    end)
  end

  defp delete_comment(current, new) do
    current
    |> Enum.reduce([], fn item, acc ->
      case item.id == new.id do
        true -> acc
        false -> [item | acc]
      end
    end)
    |> Enum.reverse()
  end
end
