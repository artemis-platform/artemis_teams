defmodule ArtemisWeb.RecognitionCardComponent do
  use Phoenix.LiveComponent

  alias Artemis.CreateReaction

  # LiveView Callbacks

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:recognition, assigns.recognition)
      |> assign(:user, assigns.user)
      |> assign_recognition_comments(assigns)
      |> assign_recognition_reactions(assigns)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "show/_card.html", assigns)
  end

  # Callbacks

  @impl true
  def handle_event("create-reaction", %{"value" => value}, socket) do
    params = %{
      resource_id: Integer.to_string(socket.assigns.recognition.id),
      resource_type: "Recognition",
      user_id: socket.assigns.user.id,
      value: value
    }

    {:ok, _} = CreateReaction.call(params, socket.assigns.user)

    {:noreply, socket}
  end

  # Helpers

  defp assign_recognition_comments(socket, %{comments: comments}) when is_list(comments) do
    recognition_id = Integer.to_string(socket.assigns.recognition.id)
    filtered_comments = Enum.filter(comments, &(&1.resource_id == recognition_id))

    socket
    |> assign(:recognition_comments, filtered_comments)
    |> assign(:recognition_comments_count, length(filtered_comments))
    |> assign(:recognition_comments_status, :loaded)
  end

  defp assign_recognition_comments(socket, _assigns) do
    assign(socket, :recognition_comments_status, :loading)
  end

  defp assign_recognition_reactions(socket, %{reactions: reactions}) when is_list(reactions) do
    recognition_id = Integer.to_string(socket.assigns.recognition.id)
    filtered_reactions = Enum.filter(reactions, &(&1.resource_id == recognition_id))

    socket
    |> assign(:recognition_reactions, filtered_reactions)
    |> assign(:recognition_reactions_count, length(filtered_reactions))
    |> assign(:recognition_reactions_status, :loaded)
  end

  defp assign_recognition_reactions(socket, _assigns) do
    assign(socket, :recognition_reactions_status, :loading)
  end
end
