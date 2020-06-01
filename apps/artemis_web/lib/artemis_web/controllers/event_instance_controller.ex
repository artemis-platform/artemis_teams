defmodule ArtemisWeb.EventInstanceController do
  use ArtemisWeb, :controller

  alias Artemis.DeleteEventAnswer
  alias Artemis.EventAnswer
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventAnswers
  alias Artemis.ListEventIntegrations
  alias Artemis.ListEventQuestions
  alias Artemis.ListProjects
  alias Artemis.ListUserTeams
  alias Artemis.UpdateEventInstance

  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-answers:show", fn ->
      user = current_user(conn)
      today = Date.to_iso8601(Date.utc_today())
      event_template = get_event_template!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_answers = get_event_answers_for_index(event_template_id, params, user)
      event_answers_by_date = get_event_answers_by_date(event_answers)
      event_instance_layout = Map.get(conn.query_params, "layout", "date")
      filter_data = get_filter_data(event_template, user)

      assigns = [
        event_answers: event_answers,
        event_answers_by_date: event_answers_by_date,
        event_instance_layout: event_instance_layout,
        event_questions: event_questions,
        event_template: event_template,
        filter_data: filter_data,
        today: today
      ]

      authorize_in_team(conn, event_template.team_id, fn ->
        render_format(conn, "index", assigns)
      end)
    end)
  end

  def show(conn, %{"event_id" => event_template_id, "id" => date} = params) do
    authorize(conn, "event-answers:show", fn ->
      user = current_user(conn)
      event_template = get_event_template!(event_template_id, user)
      event_answers = get_event_answers_for_show(event_template_id, date, params, user)
      event_integrations = get_event_integrations(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_instance_layout = Map.get(conn.query_params, "layout", "date")
      filter_data = get_filter_data(event_template, user)

      assigns = [
        date: date,
        event_answers: event_answers,
        event_instance_layout: event_instance_layout,
        event_questions: event_questions,
        event_integrations: event_integrations,
        event_template: event_template,
        filter_data: filter_data
      ]

      authorize_in_team(conn, event_template.team_id, fn ->
        render(conn, "show.html", assigns)
      end)
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

      authorize_in_team(conn, event_template.team_id, fn ->
        render(conn, "edit.html", assigns)
      end)
    end)
  end

  def update(conn, %{"id" => date, "event_id" => event_template_id, "event_instance" => params}) do
    authorize(conn, "event-answers:update", fn ->
      user = current_user(conn)
      event_template = get_event_template!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_answer_params = get_event_answer_params(params)

      authorize_in_team(conn, event_template.team_id, fn ->
        case UpdateEventInstance.call(event_answer_params, event_questions, user) do
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
    end)
  end

  def delete(conn, %{"event_id" => event_template_id, "id" => date}) do
    authorize(conn, "event-answers:delete", fn ->
      user = current_user(conn)
      event_template = get_event_template!(event_template_id, user)

      authorize_in_team(conn, event_template.team_id, fn ->
        event_answers = get_event_answers_for_delete(event_template_id, date, user)
        event_answer_ids = Enum.map(event_answers, & &1.id)

        result = DeleteEventAnswer.call_many(event_answer_ids, [user])
        success? = length(result.errors) == 0

        case success? do
          true ->
            conn
            |> put_flash(:info, "Event instance answers deleted successfully.")
            |> redirect(to: Routes.event_instance_path(conn, :show, event_template_id, date))

          false ->
            conn
            |> put_flash(:error, "Error deleting event instance answers.")
            |> redirect(to: Routes.event_instance_path(conn, :show, event_template_id, date))
        end
      end)
    end)
  end

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
        page_size: 50,
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

  defp get_event_answers_for_delete(event_template_id, date, user) do
    params = %{
      filters: %{
        date: Date.from_iso8601!(date),
        event_template_id: event_template_id,
        user_id: user.id
      }
    }

    ListEventAnswers.call(params, user)
  end

  defp get_event_integrations(event_template_id, user) do
    params = %{
      filters: %{
        active: true,
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

  defp get_event_answer_params(params) do
    params
    |> Map.values()
    |> Enum.flat_map(&Map.values(&1))
  end
end
