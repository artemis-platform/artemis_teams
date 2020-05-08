defmodule ArtemisWeb.EventInstanceController do
  use ArtemisWeb, :controller

  alias Artemis.EventAnswer
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventAnswers
  alias Artemis.ListEventIntegrations
  alias Artemis.ListEventQuestions
  alias Artemis.ListProjects

  # TODO: filter by username and question
  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-answers:show", fn ->
      user = current_user(conn)
      today = Date.to_iso8601(Date.utc_today())
      event_template = get_event_template!(event_template_id, user)
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
      event_template = get_event_template!(event_template_id, user)
      event_answers = get_event_answers_for_show(event_template_id, date, user)
      event_integrations = get_event_integrations(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)

      assigns = [
        date: date,
        event_answers: event_answers,
        event_questions: event_questions,
        event_integrations: event_integrations,
        event_template: event_template
      ]

      render(conn, "show.html", assigns)
    end)
  end

  def edit(conn, %{"event_id" => event_template_id, "id" => date}) do
    authorize(conn, "event-answers:update", fn ->
      user = current_user(conn)
      event_template = get_event_template!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      projects = get_projects(event_template.team_id, user)

      existing_event_answers = get_event_answers_for_update(event_template_id, date, user)
      event_answers = add_default_event_answers(date, event_questions, existing_event_answers, user)

      assigns = [
        date: date,
        event_answers: event_answers,
        event_questions: event_questions,
        event_template: event_template,
        projects: projects
      ]

      render(conn, "edit.html", assigns)
    end)
  end

  def update(conn, %{"id" => date, "event_id" => event_template_id, "event_instance" => params}) do
    authorize(conn, "event-answers:update", fn ->
      user = current_user(conn)
      event_template = get_event_template!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_answer_params = get_event_answer_params(params)

      case record_event_answers(event_answer_params, event_questions, user) do
        {:ok, _changesets} ->
          conn
          |> put_flash(:info, "Event Instance updated successfully.")
          |> redirect(to: Routes.event_instance_path(conn, :show, event_template_id, date))

        {:error, existing_event_answers} ->
          projects = get_projects(event_template.team_id, user)
          event_answers = add_default_event_answers(date, event_questions, existing_event_answers, user)

          assigns = [
            date: date,
            event_answers: event_answers,
            event_questions: event_questions,
            event_template: event_template,
            projects: projects
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

  defp get_event_template!(event_template_id, user) do
    options = [
      preload: [:projects]
    ]

    GetEventTemplate.call!(event_template_id, user, options)
  end

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

      [{date, records} | acc]
    end)
  end

  defp get_event_answers_for_index(event_template_id, params, user) do
    required_params =
      %{
        filters: %{
          event_template_id: event_template_id
        },
        paginate: true,
        preload: [:event_question, :project, :user]
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
      preload: [:project, :user]
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
      preload: [:project, :user]
    }

    params
    |> ListEventAnswers.call(user)
    |> Enum.map(&EventAnswer.changeset(&1))
  end

  defp add_default_event_answers(date, event_questions, event_answers, user) do
    Enum.reduce(event_questions, event_answers, fn event_question, acc ->
      filtered =
        Enum.filter(event_answers, fn event_answer ->
          current = Ecto.Changeset.get_field(event_answer, :event_question_id)
          match = event_question.id

          current == match
        end)

      empty_event_answer = %Artemis.EventAnswer{
        date: date,
        event_question_id: event_question.id,
        type: event_question.type,
        user_id: user.id
      }

      empty_event_answer_changeset = Artemis.EventAnswer.changeset(empty_event_answer)

      case length(filtered) do
        0 -> [empty_event_answer_changeset | acc]
        _ -> acc
      end
    end)
  end

  defp get_projects(team_id, user) do
    params = %{
      filters: %{
        team_id: team_id
      },
      preload: [:team]
    }

    ListProjects.call(params, user)
  end

  defp get_event_integrations(event_template_id, user) do
    params = %{
      filters: %{
        event_template_id: event_template_id
      },
      preload: [:event_template]
    }

    ListEventIntegrations.call(params, user)
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

  defp record_event_answers(event_answer_params, event_questions, user) do
    Artemis.Repo.Helpers.with_transaction(fn ->
      results =
        event_answer_params
        |> filter_event_answer_params(event_questions)
        |> Enum.map(&record_event_answer(&1, user))

      error? = Enum.any?(results, &(elem(&1, 0) == :error))
      changesets = Enum.map(results, &elem(&1, 1))

      case error? do
        true -> {:error, changesets}
        false -> {:ok, changesets}
      end
    end)
  end

  defp filter_event_answer_params(event_answer_params, event_questions) do
    event_answer_params
    |> Enum.reduce([], fn params, acc ->
      event_question = get_event_question(params, event_questions)

      value_present? =
        params
        |> Map.get("value")
        |> Artemis.Helpers.present?()

      case event_question.required || value_present? do
        true -> [params | acc]
        false -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp get_event_question(event_answer_params, event_questions) do
    event_question_id =
      event_answer_params
      |> Map.fetch!("event_question_id")
      |> Artemis.Helpers.to_integer()

    Enum.find(event_questions, &(&1.id == event_question_id))
  end

  defp record_event_answer(params, user) do
    id = Map.get(params, "id")
    id? = !is_nil(id)
    delete? = Map.get(params, "delete") == "true"

    action =
      cond do
        id? && delete? -> fn _params, user -> Artemis.DeleteEventAnswer.call(id, user) end
        id? -> fn params, user -> Artemis.UpdateEventAnswer.call(id, params, user) end
        true -> fn params, user -> Artemis.CreateEventAnswer.call(params, user) end
      end

    case action.(params, user) do
      {:ok, record} -> {:ok, EventAnswer.changeset(record, params)}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, _} -> {:error, EventAnswer.changeset(%EventAnswer{}, params)}
    end
  rescue
    _ in DBConnection.ConnectionError ->
      id = Map.get(params, "id")
      struct = %EventAnswer{id: id}
      changeset = EventAnswer.changeset(struct, params)

      {:error, changeset}

    error ->
      reraise error, __STACKTRACE__
  end
end
