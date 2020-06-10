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
    resource_type = Map.fetch!(session, "resource_type")
    resource_id = Map.fetch!(session, "resource_id")
    comment = get_comment(session)
    changeset = Comment.changeset(comment)
    action = if comment.id, do: :update, else: :create
    redirect? = Map.get(session, "redirect", true)

    assigns =
      socket
      |> assign(:action, action)
      |> assign(:changeset, changeset)
      |> assign(:comment, comment)
      |> assign(:resource_id, resource_id)
      |> assign(:resource_type, resource_type)
      |> assign(:redirect?, redirect?)
      |> assign(:status, :unsubmitted)
      |> assign(:user, user)

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.CommentView, "form-live.html", assigns)
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
    redirect? = socket.assigns.redirect?
    user = socket.assigns.user
    params = get_params(socket, params)
    id = Map.get(params, "id")

    case UpdateComment.call(id, params, user) do
      {:ok, comment} ->
        case redirect? do
          true ->
            socket
            |> put_flash(:info, "Comment updated successfully.")
            |> redirect(to: ArtemisWeb.Router.Helpers.home_path(socket, :index))

          _ ->
            socket
            |> assign(:comment, comment)
            |> assign(:status, :success)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        comment = GetComment.call(id, user, preload: [:users])

        socket
        |> assign(:changeset, changeset)
        |> assign(:comment, comment)
        |> assign(:status, :submitted)
    end
  end

  # Helpers

  defp get_comment(%{"comment" => comment}), do: comment
  defp get_comment(_session), do: %Comment{}

  defp get_params(socket, params) do
    params
    |> Artemis.Helpers.keys_to_strings(params)
    |> Map.put("resource_id", Artemis.Helpers.to_string(socket.assigns.resource_id))
    |> Map.put("resource_type", socket.assigns.resource_type)
  end
end
