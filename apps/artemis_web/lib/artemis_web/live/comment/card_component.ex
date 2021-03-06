defmodule ArtemisWeb.CommentCardComponent do
  use Phoenix.LiveComponent

  alias Artemis.DeleteComment

  # LiveView Callbacks

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:comment, assigns.comment)
      |> assign(:path, assigns.path)
      |> assign(:reactions, assigns.reactions)
      |> assign(:user, assigns.user)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.CommentView, "_card.html", assigns)
  end

  # Callbacks

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} = DeleteComment.call(id, socket.assigns.user)

    {:noreply, socket}
  end
end
