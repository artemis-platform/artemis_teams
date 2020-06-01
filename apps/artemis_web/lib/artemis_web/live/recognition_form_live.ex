defmodule ArtemisWeb.RecognitionFormLive do
  use ArtemisWeb.LiveView

  alias Artemis.CreateRecognition
  alias Artemis.GetRecognition
  alias Artemis.GetSystemUser
  alias Artemis.ListUsers
  alias Artemis.Recognition
  alias Artemis.UpdateRecognition

  # LiveView Callbacks

  @impl true
  def mount(_params, session, socket) do
    user = Map.get(session, "user")
    recognition = get_recognition(session)
    changeset = Recognition.changeset(recognition)
    action = if recognition.id, do: :update, else: :create
    redirect? = Map.get(session, "redirect", true)

    assigns =
      socket
      |> assign(:action, action)
      |> assign(:changeset, changeset)
      |> assign(:recognition, recognition)
      |> assign(:redirect?, redirect?)
      |> assign(:status, :unsubmitted)
      |> assign(:user, user)
      |> assign(:user_options, get_user_options(user))

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "form.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_event("reset", _params, socket) do
    recognition = get_recognition(:new)
    changeset = Recognition.changeset(recognition)

    assigns =
      socket
      |> assign(:changeset, changeset)
      |> assign(:recognition, recognition)
      |> assign(:status, :unsubmitted)

    {:noreply, assigns}
  end

  def handle_event("submit", %{"recognition" => params}, socket) do
    socket =
      case socket.assigns.action do
        :create -> create(socket, params)
        :update -> update(socket, params)
      end

    {:noreply, socket}
  end

  # Actions

  defp create(socket, params) do
    redirect? = socket.assigns.redirect?
    user = socket.assigns.user
    params = get_params(params, user)

    case CreateRecognition.call(params, user) do
      {:ok, recognition} ->
        case redirect? do
          true ->
            socket
            |> put_flash(:info, "Recognition created successfully.")
            |> redirect(to: ArtemisWeb.Router.Helpers.recognition_path(socket, :show, recognition))

          _ ->
            socket
            |> assign(:recognition, recognition)
            |> assign(:status, :success)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        recognition = %Recognition{user_recognitions: []}

        socket
        |> assign(:changeset, changeset)
        |> assign(:recognition, recognition)
        |> assign(:status, :submitted)
    end
  end

  defp update(socket, params) do
    redirect? = socket.assigns.redirect?
    user = socket.assigns.user
    params = get_params(params, user)
    id = Map.get(params, "id")

    case UpdateRecognition.call(id, params, user) do
      {:ok, recognition} ->
        case redirect? do
          true ->
            socket
            |> put_flash(:info, "Recognition updated successfully.")
            |> redirect(to: ArtemisWeb.Router.Helpers.recognition_path(socket, :show, recognition))

          _ ->
            socket
            |> assign(:recognition, recognition)
            |> assign(:status, :success)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        recognition = GetRecognition.call(id, user, preload: [:users])

        socket
        |> assign(:changeset, changeset)
        |> assign(:recognition, recognition)
        |> assign(:status, :submitted)
    end
  end

  # Helpers

  defp get_recognition(%{"recognition" => recognition}), do: recognition
  defp get_recognition(_), do: %Recognition{user_recognitions: []}

  defp get_user_options(user) do
    GetSystemUser.call!()
    |> ListUsers.call()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp get_params(params, user) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put("created_by", user)
    |> Map.put("created_by_id", user.id)
    |> Map.put_new("user_recognitions", [])
    |> maybe_add_user_recognitions()
  end

  defp maybe_add_user_recognitions(%{"user_recognitions" => user_ids} = params) when is_list(user_ids) do
    user_recognitions = Enum.map(user_ids, &%{user_id: &1})

    Map.put(params, "user_recognitions", user_recognitions)
  end

  defp maybe_add_user_recognitions(params), do: params
end
