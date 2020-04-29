defmodule ArtemisWeb.EventInstanceController do
  use ArtemisWeb, :controller

  alias Artemis.EventAnswer
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventAnswers
  alias Artemis.ListEventQuestions

  # TODO: filter by username and question
  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-answers:show", fn ->
      user = current_user(conn)
      today = Date.to_iso8601(Date.utc_today())
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_answers = get_event_answers_for_index(event_template_id, params, user)
      event_answers_by_date = get_event_answers_by_date(event_answers)

      assigns = [
        event_answers: event_answers,
        event_answers_by_date: event_answers_by_date,
        event_questions: event_questions,
        event_template: event_template,
        today: today
      ]

      render(conn, "index.html", assigns)
    end)
  end

  def show(conn, %{"event_id" => event_template_id, "id" => date}) do
    authorize(conn, "event-answers:show", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_answers = get_event_answers_for_show(event_template_id, date, user)
      event_questions = get_event_questions(event_template_id, user)

      assigns = [
        date: date,
        event_answers: event_answers,
        event_questions: event_questions,
        event_template: event_template
      ]

      render(conn, "show.html", assigns)
    end)
  end

  def edit(conn, %{"event_id" => event_template_id, "id" => date}) do
    authorize(conn, "event-answers:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_answers = get_event_answers_for_update(event_template_id, date, user)
      event_questions = get_event_questions(event_template_id, user)

      assigns = [
        date: date,
        event_answers: event_answers,
        event_questions: event_questions,
        event_template: event_template
      ]

      render(conn, "edit.html", assigns)
    end)
  end

  def update(conn, %{"id" => date, "event_id" => event_template_id, "event_instance" => params}) do
    authorize(conn, "event-answers:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_answer_params = get_event_answer_params(params)

      case create_or_update_event_answers(event_answer_params, user) do
        {:ok, _changesets} ->
          conn
          |> put_flash(:info, "Event Instance updated successfully.")
          |> redirect(to: Routes.event_instance_path(conn, :show, event_template_id, date))

        {:error, event_answers} ->
          event_questions = get_event_questions(event_template_id, user)

          assigns = [
            date: date,
            event_answers: event_answers,
            event_questions: event_questions,
            event_template: event_template
          ]

          render(conn, "edit.html", assigns)
      end
    end)
  end

  # TODO: how to delete an answer?
  #   def delete(conn, %{"event_id" => event_template_id, "id" => id} = params) do
  #     authorize(conn, "event-answers:delete", fn ->
  #       {:ok, _event_instance} = DeleteEventInstance.call(id, params, current_user(conn))

  #       conn
  #       |> put_flash(:info, "Event Question deleted successfully.")
  #       |> redirect(to: Routes.event_path(conn, :show, event_template_id))
  #     end)
  #   end

  # Helpers

  defp get_event_answers_by_date(event_answers) do
    grouped =
      event_answers
      |> Map.get(:entries)
      |> Enum.group_by(& &1.date)

    grouped
    |> Map.keys()
    |> Artemis.Helpers.DateTime.sort_by_date()
    |> Enum.reduce([], fn date, acc ->
      records = Map.get(grouped, date)
      date_string = Date.to_iso8601(date)

      [{date_string, records} | acc]
    end)
  end

  defp get_event_answers_for_index(event_template_id, params, user) do
    required_params =
      %{
        filters: %{
          event_template_id: event_template_id
        },
        paginate: true,
        preload: [:event_question, :user]
      }
      |> Artemis.Helpers.keys_to_strings()

    event_answer_params =
      params
      |> Map.delete("preload")
      |> Map.delete("event_template_id")
      |> Artemis.Helpers.deep_merge(required_params)

    ListEventAnswers.call(event_answer_params, user)
  end

  defp get_event_answers_for_show(event_template_id, date, user) do
    params = %{
      filters: %{
        date: Date.from_iso8601!(date),
        event_template_id: event_template_id
      },
      preload: [:user]
    }

    ListEventAnswers.call(params, user)
  end

  defp get_event_answers_for_update(event_template_id, date, user) do
    params = %{
      filters: %{
        date: Date.from_iso8601!(date),
        event_template_id: event_template_id,
        user_id: user.id
      },
      preload: [:user]
    }

    params
    |> ListEventAnswers.call(user)
    |> Enum.map(&EventAnswer.changeset(&1))
  end

  # TODO: update questions with a deleted_at date field. Then only return those in range.
  defp get_event_questions(event_template_id, user) do
    params = %{
      filters: %{
        event_template_id: event_template_id
      },
      preload: [:event_template]
    }

    ListEventQuestions.call(params, user)
  end

  # Helpers - Update Event Instance

  defp get_event_answer_params(params) do
    params
    |> Map.values()
    |> Enum.flat_map(&Map.values(&1))
  end

  defp create_or_update_event_answers(event_answer_params, user) do
    Artemis.Repo.Helpers.with_transaction(fn ->
      results = Enum.map(event_answer_params, &create_or_update_event_answer(&1, user))
      error? = Enum.any?(results, &(elem(&1, 0) == :error))
      changesets = Enum.map(results, &elem(&1, 1))

      case error? do
        true -> {:error, changesets}
        false -> {:ok, changesets}
      end
    end)
  end

  defp create_or_update_event_answer(params, user) do
    action =
      case Map.get(params, "id") do
        nil -> fn params, user -> Artemis.CreateEventAnswer.call(params, user) end
        id -> fn params, user -> Artemis.UpdateEventAnswer.call(id, params, user) end
      end

    case action.(params, user) do
      {:ok, _record} -> {:ok, EventAnswer.changeset(%EventAnswer{}, params)}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, _} -> {:error, EventAnswer.changeset(%EventAnswer{}, params)}
    end
  rescue
    _ in DBConnection.ConnectionError -> {:error, EventAnswer.changeset(%EventAnswer{}, params)}
    error -> reraise error, __STACKTRACE__
  end
end
