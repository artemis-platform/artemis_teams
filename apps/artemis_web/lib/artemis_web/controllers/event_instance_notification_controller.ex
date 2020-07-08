defmodule ArtemisWeb.EventInstanceNotificationController do
  use ArtemisWeb, :controller

  alias Artemis.CreateEventNotification
  alias Artemis.GetEventIntegration
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventAnswers
  alias Artemis.ListUserTeams

  def create(conn, %{"event_id" => event_template_id, "event_instance_id" => date, "id" => id}) do
    authorize(conn, "event-integrations:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      authorize_in_team(conn, event_template.team_id, fn ->
        case create_event_instance_notification(conn, event_template, date, id) do
          {:ok, _response} ->
            conn
            |> put_flash(:info, "Event Notification created successfully.")
            |> redirect(to: Routes.event_instance_path(conn, :show, event_template.id, date))

          {:error, _error} ->
            conn
            |> put_flash(:error, "Error creating Event Notification.")
            |> redirect(to: Routes.event_instance_path(conn, :show, event_template.id, date))
        end
      end)
    end)
  end

  # Helpers

  defp create_event_instance_notification(conn, event_template, date, id) do
    user = current_user(conn)
    event_integration = GetEventIntegration.call!([id: id, event_template_id: event_template.id], user)
    url = Artemis.Helpers.deep_get(event_integration, [:settings, "webhook_url"])

    case event_integration.notification_type do
      "Reminder" -> create_reminder_notification(conn, event_template, date, url, user)
      "Summary - By Project" -> create_summary_by_project_notification(conn, event_template, date, url, user)
    end
  end

  defp create_reminder_notification(conn, event_template, date, url, user) do
    module = ArtemisWeb.EventInstanceView
    template = "show/_reminder.slack"

    assigns = [
      conn: conn,
      date: date,
      event_template: event_template,
      user: user
    ]

    payload = Phoenix.View.render_to_string(module, template, assigns)

    CreateEventNotification.call(%{payload: payload, url: url}, user)
  end

  defp create_summary_by_project_notification(conn, event_template, date, url, user) do
    event_answers = get_event_answers(event_template, date, user)
    respondents = get_respondents(event_template.team_id, event_answers, user)

    # Summary Overview Section

    module = ArtemisWeb.EventInstanceView
    template = "show/_summary_overview.slack"

    assigns = [
      conn: conn,
      date: date,
      event_template: event_template,
      event_answers: event_answers,
      respondents: respondents,
      user: user
    ]

    payload = Phoenix.View.render_to_string(module, template, assigns)

    {:ok, _} = CreateEventNotification.call(%{payload: payload, url: url}, user)

    # Summary By Project Sections

    event_answers
    |> group_event_answers_by(:project)
    |> Enum.map(fn {project, grouped_event_questions} ->
      module = ArtemisWeb.EventInstanceView
      template = "show/_summary_by_project.slack"

      assigns = [
        event_questions: grouped_event_questions,
        project: project
      ]

      payload = Phoenix.View.render_to_string(module, template, assigns)

      {:ok, _} = CreateEventNotification.call(%{payload: payload, url: url}, user)
    end)

    {:ok, true}
  end

  defp get_event_answers(event_template, date, user) do
    event_question_visibility_filter =
      ArtemisWeb.EventQuestionView.get_event_question_visibility(
        event_template.team_id,
        user
      )

    params = %{
      filters: %{
        date: Date.from_iso8601!(date),
        event_question_visibility: event_question_visibility_filter,
        event_template_id: event_template.id
      },
      preload: [:event_question, :project, :user]
    }

    ListEventAnswers.call(params, user)
  end

  defp group_event_answers_by(event_answers, :project) do
    event_answers
    |> Enum.sort_by(
      &{
        Artemis.Helpers.deep_get(&1, [:project, :title]),
        &1.event_question.order,
        &1.event_question.inserted_at,
        &1.user.name
      }
    )
    |> Enum.group_by(& &1.project)
    |> Enum.map(fn {project, event_answers} ->
      grouped_by_event_question = Enum.group_by(event_answers, & &1.event_question)

      {project, grouped_by_event_question}
    end)
  end

  defp get_respondents(team_id, event_answers, user) do
    params = %{
      filters: %{
        team_id: team_id,
        type: ["admin", "member"]
      },
      preload: [:user]
    }

    potential_respondents = ListUserTeams.call(params, user)

    actual_respondent_ids =
      event_answers
      |> Enum.map(& &1.user.id)
      |> Enum.uniq()

    grouped = Enum.split_with(potential_respondents, &Enum.member?(actual_respondent_ids, &1.user.id))

    %{
      responded: elem(grouped, 0),
      no_response: elem(grouped, 1)
    }
  end
end
