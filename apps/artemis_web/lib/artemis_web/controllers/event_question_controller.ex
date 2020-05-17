defmodule ArtemisWeb.EventQuestionController do
  use ArtemisWeb, :controller

  alias Artemis.CreateEventQuestion
  alias Artemis.DeleteEventQuestion
  alias Artemis.EventQuestion
  alias Artemis.GetEventQuestion
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventQuestions
  alias Artemis.UpdateEventQuestion

  @preload [:event_template]

  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-questions:list", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      params =
        params
        |> Map.put(:paginate, true)
        |> Map.put(:preload, @preload)

      event_questions = ListEventQuestions.call(params, user)

      assigns = [
        event_questions: event_questions,
        event_template: event_template
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, %{"event_id" => event_template_id}) do
    authorize(conn, "event-questions:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_question = %EventQuestion{event_template_id: event_template_id}
      changeset = EventQuestion.changeset(event_question)

      assigns = [
        changeset: changeset,
        event_question: event_question,
        event_template: event_template
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"event_question" => params, "event_id" => event_template_id}) do
    authorize(conn, "event-questions:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      params = Map.put(params, "event_template_id", event_template_id)

      case CreateEventQuestion.call(params, user) do
        {:ok, _event_question} ->
          conn
          |> put_flash(:info, "Event Question created successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_question = %EventQuestion{event_template_id: event_template_id}

          assigns = [
            changeset: changeset,
            event_question: event_question,
            event_template: event_template
          ]

          render(conn, "new.html", assigns)
      end
    end)
  end

  def show(conn, %{"event_id" => event_template_id, "id" => id}) do
    authorize(conn, "event-questions:show", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_question = GetEventQuestion.call!(id, user, preload: @preload)

      assigns = [
        event_question: event_question,
        event_template: event_template
      ]

      render(conn, "show.html", assigns)
    end)
  end

  def edit(conn, %{"event_id" => event_template_id, "id" => id}) do
    authorize(conn, "event-questions:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_question = GetEventQuestion.call(id, user, preload: @preload)
      changeset = EventQuestion.changeset(event_question)

      assigns = [
        changeset: changeset,
        event_question: event_question,
        event_template: event_template
      ]

      render(conn, "edit.html", assigns)
    end)
  end

  def update(conn, %{"id" => id, "event_id" => event_template_id, "event_question" => params}) do
    authorize(conn, "event-questions:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      params = Map.put(params, "event_template_id", event_template_id)

      case UpdateEventQuestion.call(id, params, user) do
        {:ok, _event_question} ->
          conn
          |> put_flash(:info, "Event Question updated successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_question = GetEventQuestion.call(id, user, preload: @preload)

          assigns = [
            changeset: changeset,
            event_question: event_question,
            event_template: event_template
          ]

          render(conn, "edit.html", assigns)
      end
    end)
  end

  def delete(conn, %{"event_id" => event_template_id, "id" => id} = params) do
    authorize(conn, "event-questions:delete", fn ->
      {:ok, _event_question} = DeleteEventQuestion.call(id, params, current_user(conn))

      conn
      |> put_flash(:info, "Event Question deleted successfully.")
      |> redirect(to: Routes.event_path(conn, :show, event_template_id))
    end)
  end
end
