defmodule ArtemisWeb.ReactionsComponent do
  use Phoenix.LiveComponent

  alias Artemis.CreateReaction
  alias Artemis.DeleteReaction

  # LiveView Callbacks

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:resource_id, get_resource_id(assigns))
      |> assign(:resource_type, assigns.resource_type)
      |> assign(:user, assigns.user)
      |> assign_resource_reactions(assigns)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.ReactionView, "index.html", assigns)
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

  defp assign_resource_reactions(socket, %{reactions: reactions}) when is_list(reactions) do
    resource_id = socket.assigns.resource_id
    filtered_reactions = Enum.filter(reactions, &(&1.resource_id == resource_id))

    socket
    |> assign(:resource_reactions, filtered_reactions)
    |> assign(:resource_reactions_count, length(filtered_reactions))
    |> assign(:resource_reactions_status, :loaded)
  end

  defp assign_resource_reactions(socket, _assigns) do
    socket
    |> assign(:resource_reactions, [])
    |> assign(:resource_reactions_count, 0)
    |> assign(:resource_reactions_status, :loading)
  end
end
