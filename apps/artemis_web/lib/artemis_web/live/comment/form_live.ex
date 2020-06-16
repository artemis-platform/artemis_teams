defmodule ArtemisWeb.CommentFormLive do
  use ArtemisWeb.LiveView

  alias Artemis.Comment
  alias Artemis.CreateComment
  alias Artemis.GetComment
  alias Artemis.UpdateComment

  # LiveView Callbacks

  @impl true
  def mount(_params, session, socket) do
    user = Map.fetch!(session, "user")
    comment = get_comment(session, user)
    changeset = Comment.changeset(comment)
    action = if comment.id, do: :update, else: :create
    redirect_to = Map.get(session, "redirect_to")
    resource_type = Map.fetch!(session, "resource_type")
    resource_id = Map.fetch!(session, "resource_id")

    assigns =
      socket
      |> assign(:action, action)
      |> assign(:changeset, changeset)
      |> assign(:comment, comment)
      |> assign(:redirect_to, redirect_to)
      |> assign(:resource_id, resource_id)
      |> assign(:resource_type, resource_type)
      |> assign(:status, :unsubmitted)
      |> assign(:user, user)

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.CommentView, "form_live.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_event("submit", %{"comment" => params}, socket) do
    socket =
      case socket.assigns.action do
        :create -> create(socket, params)
        :update -> update(socket, params)
      end

    {:noreply, socket}
  end

  # Actions

  defp create(socket, params) do
    user = socket.assigns.user

    create_params =
      socket
      |> get_params(params)
      |> Map.put("user_id", user.id)

    case CreateComment.call(create_params, user) do
      {:ok, created_comment} ->
        new_changeset = Comment.changeset(%Comment{})

        socket
        |> assign(:changeset, new_changeset)
        |> assign(:comment, created_comment)
        |> assign(:status, :success)

      {:error, %Ecto.Changeset{} = changeset} ->
        comment = %Comment{}

        socket
        |> assign(:changeset, changeset)
        |> assign(:comment, comment)
        |> assign(:status, :submitted)
    end
  end

  defp update(socket, params) do
    user = socket.assigns.user
    params = get_params(socket, params)
    id = Map.get(params, "id")

    case UpdateComment.call(id, params, user) do
      {:ok, comment} ->
        case socket.assigns.redirect_to do
          nil ->
            new_changeset = Comment.changeset(comment)

            socket
            |> assign(:changeset, new_changeset)
            |> assign(:comment, comment)
            |> assign(:status, :success)

          redirect_to ->
            socket
            |> put_flash(:info, "Successfully updated Comment")
            |> Phoenix.LiveView.push_redirect(to: redirect_to)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        comment = GetComment.call(id, user)

        socket
        |> assign(:changeset, changeset)
        |> assign(:comment, comment)
        |> assign(:status, :submitted)
    end
  end

  # Helpers

  defp get_comment(%{"comment" => comment}, _user), do: comment
  defp get_comment(%{"id" => id}, user), do: GetComment.call(id, user)
  defp get_comment(_session, _user), do: %Comment{}

  defp get_params(socket, params) do
    params
    |> Artemis.Helpers.keys_to_strings(params)
    |> Map.put("resource_id", Artemis.Helpers.to_string(socket.assigns.resource_id))
    |> Map.put("resource_type", socket.assigns.resource_type)
  end
end
