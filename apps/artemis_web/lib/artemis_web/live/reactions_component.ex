defmodule ArtemisWeb.ReactionsComponent do
  use Phoenix.LiveComponent

  alias Artemis.CreateReaction
  alias Artemis.DeleteReaction

  # LiveView Callbacks

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:available_reactions, get_available_reactions())
      |> assign(:id, assigns.id)
      |> assign(:resource_id, get_resource_id(assigns))
      |> assign(:resource_type, assigns.resource_type)
      |> assign(:user, assigns.user)
      |> assign_resource_reactions(assigns)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.ReactionView, "_list.html", assigns)
  end

  # Callbacks

  @impl true
  def handle_event("create", %{"value" => value}, socket) do
    params = %{
      resource_id: socket.assigns.resource_id,
      resource_type: socket.assigns.resource_type,
      user_id: socket.assigns.user.id,
      value: value
    }

    {:ok, _} = CreateReaction.call(params, socket.assigns.user)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} = DeleteReaction.call(id, socket.assigns.user)

    {:noreply, socket}
  end

  # Helpers

  defp get_resource_id(%{id: id}) when is_integer(id), do: Integer.to_string(id)
  defp get_resource_id(%{id: id}), do: id

  defp get_available_reactions() do
    [
      ":thumbsup:",
      ":tada:",
      ":100:",
      ":smile:",
      ":sweat_smile:",
      ":joy:"
    ]
  end

  defp assign_resource_reactions(socket, %{reactions: reactions}) when is_list(reactions) do
    resource_id = socket.assigns.resource_id
    user_id = socket.assigns.user.id
    filtered_reactions = Enum.filter(reactions, &(&1.resource_id == resource_id))
    grouped_reactions = Enum.group_by(filtered_reactions, & &1.value)

    user_reactions =
      Enum.reduce(filtered_reactions, %{}, fn reaction, acc ->
        case reaction.user_id == user_id do
          true -> Map.put(acc, reaction.value, reaction.id)
          false -> acc
        end
      end)

    socket
    |> assign(:resource_reactions_by_value, grouped_reactions)
    |> assign(:resource_reactions_count, length(filtered_reactions))
    |> assign(:resource_reactions_status, :loaded)
    |> assign(:resource_user_reactions, user_reactions)
  end

  defp assign_resource_reactions(socket, _assigns) do
    socket
    |> assign(:resource_reactions_by_value, %{})
    |> assign(:resource_reactions_count, 0)
    |> assign(:resource_reactions_status, :loading)
    |> assign(:resource_user_reactions, %{})
  end
end
