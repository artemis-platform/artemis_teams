defmodule ArtemisWeb.CommentCardsLive do
  use ArtemisWeb.LiveView

  alias Artemis.ListComments
  alias Artemis.ListReactions

  # LiveView Callbacks

  @impl true
  def mount(_params, session, socket) do
    user = Map.get(session, "user")
    comments = Map.get(session, "comments", :loading)
    reload_on_create_event = Map.get(session, "reload_on_create_event", true)
    params = Map.get(session, "params", %{})
    path = Map.fetch!(session, "path")
    resource_id = Map.fetch!(session, "resource_id")
    resource_type = Map.fetch!(session, "resource_type")
    broadcast_topic = Artemis.Event.get_broadcast_topic()

    assigns =
      socket
      |> assign(:params, params)
      |> assign(:path, path)
      |> assign(:reactions, :loading)
      |> assign(:resource_id, resource_id)
      |> assign(:resource_type, resource_type)
      |> assign(:comments, comments)
      |> assign(:reload_on_create_event, reload_on_create_event)
      |> assign(:user, user)

    if connected?(socket), do: Process.send_after(self(), :async_load_data, 10)

    :ok = ArtemisPubSub.subscribe(broadcast_topic)

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.CommentView, "_cards.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_info(:async_load_data, socket) do
    socket =
      socket
      |> maybe_load_comments()
      |> load_reactions()

    {:noreply, socket}
  end

  def handle_info(%{event: "reaction:created", payload: payload}, socket) do
    reactions = maybe_add_reaction(socket, payload)

    {:noreply, assign(socket, :reactions, reactions)}
  end

  def handle_info(%{event: "reaction:updated", payload: payload}, socket) do
    reactions = maybe_update_reaction(socket, payload)

    {:noreply, assign(socket, :reactions, reactions)}
  end

  def handle_info(%{event: "reaction:deleted", payload: payload}, socket) do
    reactions = maybe_delete_reaction(socket, payload)

    {:noreply, assign(socket, :reactions, reactions)}
  end

  def handle_info(%{event: "comment:created", payload: _payload}, socket) do
    socket = if socket.assigns.reload_on_create_event, do: load_comments(socket), else: socket

    {:noreply, socket}
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

  defp maybe_load_comments(socket) do
    case socket.assigns.comments do
      :loading -> load_comments(socket)
      _ -> socket
    end
  end

  defp load_reactions(socket) do
    params = %{
      filters: %{
        resource_id: get_ids(socket),
        resource_type: "Comment"
      }
    }

    reactions = ListReactions.call(params, socket.assigns.user)

    assign(socket, :reactions, reactions)
  end

  defp maybe_add_reaction(socket, payload) do
    case resource_type_match?(payload) && resource_id_match?(socket, payload) do
      true -> [payload.data | socket.assigns.reactions]
      false -> socket.assigns.reactions
    end
  end

  defp maybe_update_reaction(socket, payload) do
    case resource_type_match?(payload) && resource_id_match?(socket, payload) do
      true -> update_entries(socket.assigns.reactions, payload.data)
      false -> socket.assigns.reactions
    end
  end

  defp maybe_delete_reaction(socket, payload) do
    case resource_type_match?(payload) && resource_id_match?(socket, payload) do
      true -> delete_entries(socket.assigns.reactions, payload.data)
      false -> socket.assigns.reactions
    end
  end

  defp maybe_update_comment(socket, payload) do
    case id_match?(socket, payload) do
      true -> update_entries(socket.assigns.comments, payload.data)
      false -> socket.assigns.comments
    end
  end

  defp maybe_delete_comment(socket, payload) do
    case id_match?(socket, payload) do
      true -> delete_entries(socket.assigns.comments, payload.data)
      false -> socket.assigns.comments
    end
  end

  # Helpers

  defp load_comments(socket) do
    user = socket.assigns.user

    default_params = %{
      filters: %{
        resource_id: socket.assigns.resource_id,
        resource_type: socket.assigns.resource_type
      }
    }

    required_params = %{
      paginate: false,
      preload: [:user]
    }

    params =
      default_params
      |> Artemis.Helpers.keys_to_strings()
      |> Map.merge(Artemis.Helpers.keys_to_strings(socket.assigns.params))
      |> Map.merge(Artemis.Helpers.keys_to_strings(required_params))

    comments = ListComments.call(params, user)

    assign(socket, :comments, comments)
  end

  defp get_ids(socket) do
    socket.assigns
    |> Map.get(:comments)
    |> Enum.map(&Integer.to_string(&1.id))
  end

  defp id_match?(socket, payload) do
    Enum.member?(get_ids(socket), Integer.to_string(payload.data.id))
  end

  defp resource_type_match?(payload), do: payload.data.resource_type == "Comment"

  defp resource_id_match?(socket, payload) do
    Enum.member?(get_ids(socket), payload.data.resource_id)
  end

  defp update_entries(%Scrivener.Page{entries: entries} = current, new) do
    Map.put(current, :entries, update_entries(entries, new))
  end

  defp update_entries(current, new) do
    Enum.map(current, fn item ->
      case item.id == new.id do
        true -> new
        false -> item
      end
    end)
  end

  defp delete_entries(%Scrivener.Page{entries: entries} = current, new) do
    Map.put(current, :entries, delete_entries(entries, new))
  end

  defp delete_entries(current, new) do
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
