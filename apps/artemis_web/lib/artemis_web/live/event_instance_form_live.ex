defmodule ArtemisWeb.EventInstanceFormLive do
  use ArtemisWeb.LiveView

  # LiveView Callbacks

  @impl true
  def mount(_params, session, socket) do
    event_answers_with_defaults =
      add_default_event_answers(
        session["event_answers"],
        session["date"],
        session["event_questions"],
        session["user"]
      )

    assigns =
      socket
      |> assign(:action, session["action"])
      |> assign(:csrf_token, session["csrf_token"])
      |> assign(:date, session["date"])
      |> assign(:event_answers, event_answers_with_defaults)
      |> assign(:event_questions, session["event_questions"])
      |> assign(:event_template, session["event_template"])
      |> assign(:projects, session["projects"])
      |> assign(:user, session["user"])

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.EventInstanceView, "form.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_event("create", values, socket) do
    date = Map.get(values, "date")
    event_question_id = String.to_integer(Map.get(values, "event_question_id"))
    event_question_type = Map.get(values, "event_question_type")
    user_id = String.to_integer(Map.get(values, "user_id"))

    new_event_answer = create_event_answer_changeset(date, event_question_id, event_question_type, user_id)
    updated_event_answers = socket.assigns.event_answers ++ [new_event_answer]

    socket = assign(socket, :event_answers, updated_event_answers)

    {:noreply, socket}
  end

  def handle_event("delete", %{"changeset_id" => changeset_id}, socket) do
    updated_event_answers =
      socket.assigns.event_answers
      |> Enum.map(fn event_answer ->
        match? = Ecto.Changeset.get_field(event_answer, :changeset_id) == changeset_id

        case match? do
          true -> Ecto.Changeset.put_change(event_answer, :delete, true)
          false -> event_answer
        end
      end)
      |> add_default_event_answers(socket.assigns.date, socket.assigns.event_questions, socket.assigns.user)

    socket = assign(socket, :event_answers, updated_event_answers)

    {:noreply, socket}
  end

  # Helpers

  defp add_default_event_answers(event_answers, date, event_questions, user) do
    Enum.reduce(event_questions, event_answers, fn event_question, acc ->
      filtered =
        Enum.filter(event_answers, fn event_answer ->
          current = Ecto.Changeset.get_field(event_answer, :event_question_id)
          match? = current == event_question.id
          marked_for_delete? = Ecto.Changeset.get_field(event_answer, :delete)

          match? && !marked_for_delete?
        end)

      case length(filtered) do
        0 ->
          default_answer_changeset =
            create_event_answer_changeset(
              date,
              event_question.id,
              event_question.type,
              user.id
            )

          [default_answer_changeset | acc]

        _ ->
          acc
      end
    end)
  end

  defp create_event_answer_changeset(date, event_question_id, event_question_type, user_id) do
    empty_event_answer = %Artemis.EventAnswer{
      date: date,
      event_question_id: event_question_id,
      type: event_question_type,
      user_id: user_id
    }

    Artemis.EventAnswer.changeset(empty_event_answer)
  end
end
