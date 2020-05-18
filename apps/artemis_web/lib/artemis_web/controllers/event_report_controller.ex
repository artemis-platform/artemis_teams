defmodule ArtemisWeb.EventReportController do
  use ArtemisWeb, :controller

  alias Artemis.GetEventTemplate
  alias Artemis.ListEventReports
  alias Artemis.ListProjects
  alias Artemis.ListUserTeams

  def index(conn, %{"event_id" => event_template_id} = params) do
    authorize(conn, "event-reports:list", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)
      event_reports = get_event_reports(params, user)
      filter_data = get_filter_data(event_template, user)

      assigns = [
        event_reports: event_reports,
        event_template: event_template,
        filter_data: filter_data
      ]

      render_format(conn, "index", assigns)
    end)
  end

  # Helpers

  defp get_event_reports(params, user) do
    requested_event_reports = [
      :event_instance_engagement_by_date
    ]

    ListEventReports.call(requested_event_reports, params, user)
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
end
