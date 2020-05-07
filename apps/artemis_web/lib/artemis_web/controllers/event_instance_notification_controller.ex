defmodule ArtemisWeb.EventInstanceNotificationController do
  use ArtemisWeb, :controller

  alias Artemis.GetEventTemplate
  alias Artemis.ListEventAnswers
  alias Artemis.GetEventIntegration

  def create(conn, %{"event_id" => event_template_id, "event_instance_id" => date, "id" => id}) do
    authorize(conn, "event-integrations:create", fn ->
      case create_event_instance_notification(conn, event_template_id, date, id) do
        {:ok, _event_question} ->
          conn
          |> put_flash(:info, "Event Notification created successfully.")
          |> redirect(to: Routes.event_instance_path(conn, :show, event_template_id, date))

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Error creating Event Notification.")
          |> redirect(to: Routes.event_instance_path(conn, :show, event_template_id, date))
      end
    end)
  end

  # Helpers

  defp create_event_instance_notification(conn, event_template_id, date, id) do
    user = current_user(conn)
    event_template = GetEventTemplate.call!(event_template_id, user)
    event_integration = GetEventIntegration.call!([id: id, event_template_id: event_template_id], user)
    url = Artemis.Helpers.deep_get(event_integration, [:settings, "webhook_url"])

    event_answers =
      event_template
      |> Map.get(:id)
      |> get_event_answers(date, user)

    # Summary Overview Section

    module = ArtemisWeb.EventInstanceView
    template = "show/_summary_overview.slack"

    assigns = [
      conn: conn,
      date: date,
      event_template: event_template,
      event_answers: event_answers,
      user: user
    ]

    payload = Phoenix.View.render_to_string(module, template, assigns)

    {:ok, _} = Artemis.Drivers.Slack.Request.post(url, payload)

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

      {:ok, _} = Artemis.Drivers.Slack.Request.post(url, payload)
    end)

    {:ok, true}
  end

  defp get_event_answers(event_template_id, date, user) do
    params = %{
      filters: %{
        date: Date.from_iso8601!(date),
        event_template_id: event_template_id
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
end
