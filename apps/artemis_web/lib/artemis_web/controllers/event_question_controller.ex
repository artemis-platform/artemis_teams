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
      event_questions = get_event_questions(params, user)

      assigns = [
        event_questions: event_questions,
        event_template: event_template
      ]

      authorize_team_editor(conn, event_template.team_id, fn ->
        render_format(conn, "index", assigns)
      end)
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

      authorize_team_editor(conn, event_template.team_id, fn ->
        render(conn, "new.html", assigns)
      end)
    end)
  end

  def create(conn, %{"event_question" => params, "event_id" => event_template_id}) do
    authorize(conn, "event-questions:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      params = Map.put(params, "event_template_id", event_template_id)

      authorize_team_editor(conn, event_template.team_id, fn ->
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

      authorize_team_editor(conn, event_template.team_id, fn ->
        render(conn, "show.html", assigns)
      end)
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

      authorize_team_editor(conn, event_template.team_id, fn ->
        render(conn, "edit.html", assigns)
      end)
    end)
  end

  def update(conn, %{"id" => id, "event_id" => event_template_id, "event_question" => params}) do
    authorize(conn, "event-questions:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      params = Map.put(params, "event_template_id", event_template_id)

      authorize_team_editor(conn, event_template.team_id, fn ->
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
    end)
  end

  def delete(conn, %{"event_id" => event_template_id, "id" => id} = params) do
    authorize(conn, "event-questions:delete", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      authorize_team_editor(conn, event_template.team_id, fn ->
        {:ok, _event_question} = DeleteEventQuestion.call(id, params, user)

        conn
        |> put_flash(:info, "Event Question deleted successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event_template_id))
      end)
    end)
  end

  # Helpers

  defp get_event_questions(params, user) do
    required_params = %{
      filters: %{
        event_template_id: Map.fetch!(params, "event_id")
      },
      paginate: true,
      preload: @preload
    }

    event_question_params = Map.merge(params, Artemis.Helpers.keys_to_strings(required_params))

    ListEventQuestions.call(event_question_params, user)
  end
end
