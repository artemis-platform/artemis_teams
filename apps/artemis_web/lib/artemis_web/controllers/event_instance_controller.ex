defmodule ArtemisWeb.EventInstanceController do
  use ArtemisWeb, :controller

  alias Artemis.EventAnswer
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventAnswers
  alias Artemis.ListEventIntegrations
  alias Artemis.ListEventQuestions
  alias Artemis.ListProjects
  alias Artemis.ListUserTeams

  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-answers:show", fn ->
      user = current_user(conn)
      today = Date.to_iso8601(Date.utc_today())
      event_template = get_event_template!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_answers = get_event_answers_for_index(event_template_id, params, user)
      event_answers_by_date = get_event_answers_by_date(event_answers)
      filter_data = get_filter_data(event_template, user)

      assigns = [
        event_answers: event_answers,
        event_answers_by_date: event_answers_by_date,
        event_questions: event_questions,
        event_template: event_template,
        filter_data: filter_data,
        today: today
      ]

      render(conn, "index.html", assigns)
    end)
  end

  def show(conn, %{"event_id" => event_template_id, "id" => date} = params) do
    authorize(conn, "event-answers:show", fn ->
      user = current_user(conn)
      event_template = get_event_template!(event_template_id, user)
      event_answers = get_event_answers_for_show(event_template_id, date, params, user)
      event_integrations = get_event_integrations(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      filter_data = get_filter_data(event_template, user)

      assigns = [
        date: date,
        event_answers: event_answers,
        event_questions: event_questions,
        event_integrations: event_integrations,
        event_template: event_template,
        filter_data: filter_data
      ]

      render(conn, "show.html", assigns)
    end)
  end

  def edit(conn, %{"event_id" => event_template_id, "id" => date}) do
    authorize(conn, "event-answers:update", fn ->
      user = current_user(conn)
      event_template = get_event_template!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_answers = get_event_answers_for_update(event_template_id, date, user)
      projects = get_projects(event_template.team_id, user)

      assigns = [
        csrf_token: Phoenix.Controller.get_csrf_token(),
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

        {:error, event_answers} ->
          projects = get_projects(event_template.team_id, user)

          assigns = [
            csrf_token: Phoenix.Controller.get_csrf_token(),
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

  # TODO: how to delete an event instance?
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

  defp get_filter_data(event_template, user) do
    team_id = event_template.team_id

    project_options =
      team_id
      |> get_projects(user)
      |> Enum.map(&[key: &1.title, value: &1.id])

    user_options =
      team_id
      |> get_team_members(user)
      |> Enum.map(&[key: &1.user.name, value: &1.user.id])

    %{
      project_options: project_options,
      user_options: user_options
    }
  end

  defp get_event_answers_for_show(event_template_id, date, params, user) do
    required_params =
      %{
        filters: %{
          date: Date.from_iso8601!(date),
          event_template_id: event_template_id
        },
        preload: [:project, :user]
      }
      |> Artemis.Helpers.keys_to_strings()

    event_answer_params =
      params
      |> Map.delete("event_template_id")
      |> Map.delete("id")
      |> Map.delete("preload")
      |> Artemis.Helpers.deep_merge(required_params)

    ListEventAnswers.call(event_answer_params, user)
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

  defp get_projects(team_id, user) do
    params = %{
      filters: %{
        team_id: team_id
      },
      preload: [:team]
    }

    ListProjects.call(params, user)
  end

  defp get_team_members(team_id, user) do
    params = %{
      filters: %{
        team_id: team_id
      },
      preload: [:user]
    }

    ListUserTeams.call(params, user)
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
        |> process_event_answer_params()
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

      required? = event_question.required

      multiple? = event_question.multiple
      single? = !multiple?

      delete_present? = Map.get(params, "delete") == "true"
      active? = !delete_present?

      value_present? =
        params
        |> Map.get("value")
        |> Artemis.Helpers.present?()

      id_present? =
        params
        |> Map.get("id")
        |> Artemis.Helpers.present?()

      cond do
        single? && required? -> [params | acc]
        single? && id_present? -> [params | acc]
        single? && value_present? -> [params | acc]
        multiple? && required? && active? -> [params | acc]
        multiple? && id_present? -> [params | acc]
        multiple? && value_present? && active? -> [params | acc]
        true -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp process_event_answer_params(event_answer_params) do
    denominators = get_event_answer_percent_denominators(event_answer_params)

    Enum.map(event_answer_params, fn params ->
      value_percent = get_event_answer_percent_denominator_value(denominators, params)

      Map.put(params, "value_percent", value_percent)
    end)
  end

  defp get_event_answer_percent_denominators(event_answer_params) do
    Enum.reduce(event_answer_params, %{}, fn params, acc ->
      key = get_event_answer_percent_denominator_key(params)
      current = get_in(acc, key) || Decimal.new(0)
      new = get_event_answer_value_decimal(params)
      result = Decimal.add(current, new)

      Artemis.Helpers.deep_put(acc, key, result)
    end)
  end

  defp get_event_answer_percent_denominator_key(params) do
    [
      params["event_question_id"],
      params["user_id"]
    ]
  end

  defp get_event_answer_value_decimal(%{"value" => value}) do
    Decimal.new(value)
  rescue
    _e in Decimal.Error -> Decimal.new(0)
    _e in FunctionClauseErrorr -> Decimal.new(0)
  end

  defp get_event_answer_percent_denominator_value(denominators, params) do
    key = get_event_answer_percent_denominator_key(params)
    denominator = get_in(denominators, key) || Decimal.new(0)
    current = get_event_answer_value_decimal(params)

    case Decimal.equal?(denominator, 0) do
      false -> Decimal.div(current, denominator)
      true -> nil
    end
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
    to_be_deleted? = Map.get(params, "delete") == "true"

    action =
      cond do
        id? && to_be_deleted? ->
          fn _params, user -> Artemis.DeleteEventAnswer.call(id, user) end

        id? ->
          fn params, user -> Artemis.UpdateEventAnswer.call(id, params, user) end

        true ->
          fn params, user ->
            case Artemis.CreateEventAnswer.call(params, user) do
              {:ok, record} -> {:ok, Map.put(record, :id, nil)}
              error -> error
            end
          end
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
