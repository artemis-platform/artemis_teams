defmodule ArtemisWeb.EventReportController do
  use ArtemisWeb, :controller

  alias Artemis.GetEventTemplate
  alias Artemis.ListEventReports
  alias Artemis.ListEventQuestions
  alias Artemis.ListProjects
  alias Artemis.ListUserTeams

  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-reports:list", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_questions = get_event_questions(event_template_id, user)
      event_reports = get_event_reports(params, event_questions, user)
      projects = get_projects(event_template.team_id, user)
      filter_data = get_filter_data(event_template, user)

      assigns = [
        event_questions: event_questions,
        event_reports: event_reports,
        event_template: event_template,
        filter_data: filter_data,
        projects: projects
      ]

      render_format(conn, "index", assigns)
    end)
  end

  # Helpers

  defp get_event_reports(params, event_questions, user) do
    params = Artemis.Helpers.keys_to_strings(params)

    # Event Instance Reports

    requested_reports = [
      :event_instance_engagement_by_date
    ]

    event_instance_reports = ListEventReports.call(requested_reports, params, user)

    # Event Question Reports

    requested_reports = [
      :event_questions_percent_by_date
    ]

    numeric_event_question_ids =
      event_questions
      |> Enum.filter(&(&1.type == "number"))
      |> Enum.map(& &1.id)

    required_params = %{
      "filters" => %{
        "event_question_id" => numeric_event_question_ids
      }
    }

    event_question_params = Map.merge(params, required_params)

    event_question_reports = ListEventReports.call(requested_reports, event_question_params, user)

    Map.merge(event_instance_reports, event_question_reports)
  end

  defp get_filter_data(event_template, user) do
    team_id = event_template.team_id

    event_question_options =
      event_template.id
      |> get_event_questions(user)
      |> Enum.map(&[key: &1.title, value: &1.id])

    project_options =
      team_id
      |> get_projects(user)
      |> Enum.map(&[key: &1.title, value: &1.id])

    user_options =
      team_id
      |> get_team_members(user)
      |> Enum.map(&[key: &1.user.name, value: &1.user.id])

    %{
      event_question_options: event_question_options,
      project_options: project_options,
      user_options: user_options
    }
  end

  defp get_event_questions(event_template_id, user) do
    params = %{
      filters: %{
        event_template_id: event_template_id
      }
    }

    ListEventQuestions.call(params, user)
  end

  defp get_projects(team_id, user) do
    params = %{
      filters: %{
        team_id: team_id
      }
    }

    ListProjects.call(params, user)
  end

  defp get_team_members(team_id, user) do
    params = %{
      filters: %{
        team_id: team_id
      }
    }

    ListUserTeams.call(params, user)
  end
end
