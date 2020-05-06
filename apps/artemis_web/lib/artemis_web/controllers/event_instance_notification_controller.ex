defmodule ArtemisWeb.EventInstanceNotificationController do
  use ArtemisWeb, :controller

  alias Artemis.GetEventTemplate
  alias Artemis.ListEventAnswers
  alias Artemis.ListEventIntegrations

  def create(conn, %{"event_id" => event_template_id, "event_instance_id" => date}) do
    authorize(conn, "event-integrations:create", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(event_template_id, user)

      case create_event_instance_notification(conn, event_template.id, date) do
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

  defp create_event_instance_notification(conn, event_template_id, date) do
    user = current_user(conn)
    module = ArtemisWeb.EventInstanceView
    template = "show/_summary_by_project.slack"
    event_template = GetEventTemplate.call!(event_template_id, user)

    event_answers =
      event_template
      |> Map.get(:id)
      |> get_event_answers(date, user)
      |> group_event_answers_by(:project)

    assigns = [
      conn: conn,
      date: date,
      event_template: event_template,
      event_answers: event_answers,
      user: user
    ]

    # payload = Phoenix.View.render_to_string(module, template, assigns)
    # url = ""

    # IO.inspect(Artemis.Drivers.Slack.Request.post(url, payload))

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
  end
end
