defmodule ArtemisWeb.EventController do
  use ArtemisWeb, :controller

  alias Artemis.CreateEventTemplate
  alias Artemis.EventTemplate
  alias Artemis.DeleteEventTemplate
  alias Artemis.GetEventTemplate
  alias Artemis.ListEventIntegrations
  alias Artemis.ListEventQuestions
  alias Artemis.ListEventTemplates
  alias Artemis.ListTeams
  alias Artemis.UpdateEventTemplate

  @default_schedule "DTSTART:20170102T100000\nRRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR;BYHOUR=9;BYMINUTE=0;BYSECOND=0"
  @preload [:event_questions, :team]

  def index(conn, params) do
    authorize(conn, "event-templates:list", fn ->
      user = current_user(conn)
      event_templates = get_related_event_templates(params, user)

      assigns = [
        event_templates: event_templates
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, params) do
    authorize(conn, "event-templates:create", fn ->
      user = current_user(conn)
      event_template = %EventTemplate{schedule: @default_schedule}
      changeset = EventTemplate.changeset(event_template, params)
      schedule_rules_count = get_schedule_rules_count(conn, event_template)
      team_options = get_related_team_options(user)

      assigns = [
        changeset: changeset,
        event_template: event_template,
        schedule_rules_count: schedule_rules_count,
        team_options: team_options
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"event_template" => params}) do
    authorize(conn, "event-templates:create", fn ->
      user = current_user(conn)
      params = get_params(params)

      case CreateEventTemplate.call(params, user) do
        {:ok, event_template} ->
          conn
          |> put_flash(:info, "EventTemplate created successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event_template))

        {:error, %Ecto.Changeset{} = changeset} ->
          event_template = %EventTemplate{}
          schedule_rules_count = get_schedule_rules_count(conn, params)
          team_options = get_related_team_options(user)

          assigns = [
            changeset: changeset,
            event_template: event_template,
            schedule_rules_count: schedule_rules_count,
            team_options: team_options
          ]

          render(conn, "new.html", assigns)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "event-templates:show", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call!(id, user)

      event_questions_params = %{filters: %{active: true, event_template_id: event_template.id}}
      event_questions = ListEventQuestions.call(event_questions_params, user)

      event_integrations_params = %{filters: %{active: true, event_template_id: event_template.id}}
      event_integrations = ListEventIntegrations.call(event_integrations_params, user)

      assigns = [
        event_integrations: event_integrations,
        event_questions: event_questions,
        event_template: event_template,
        team_id: event_template.team_id
      ]

      authorize_in_team(conn, event_template.team_id, fn ->
        render(conn, "show.html", assigns)
      end)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "event-templates:update", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call(id, user, preload: @preload)
      changeset = EventTemplate.changeset(event_template)
      schedule_rules_count = get_schedule_rules_count(conn, event_template)
      team_options = get_related_team_options(user)

      assigns = [
        changeset: changeset,
        event_template: event_template,
        schedule_rules_count: schedule_rules_count,
        team_options: team_options
      ]

      authorize_team_editor(conn, event_template.team_id, fn ->
        render(conn, "edit.html", assigns)
      end)
    end)
  end

  def update(conn, %{"id" => id, "event_template" => params}) do
    authorize(conn, "event-templates:update", fn ->
      user = current_user(conn)
      params = get_params(params)
      event_template = GetEventTemplate.call(id, user, preload: @preload)

      authorize_team_editor(conn, event_template.team_id, fn ->
        case UpdateEventTemplate.call(id, params, user) do
          {:ok, event_template} ->
            conn
            |> put_flash(:info, "EventTemplate updated successfully.")
            |> redirect(to: Routes.event_path(conn, :show, event_template))

          {:error, %Ecto.Changeset{} = changeset} ->
            schedule_rules_count = get_schedule_rules_count(conn, params)
            team_options = get_related_team_options(user)

            assigns = [
              changeset: changeset,
              event_template: event_template,
              schedule_rules_count: schedule_rules_count,
              team_options: team_options
            ]

            render(conn, "edit.html", assigns)
        end
      end)
    end)
  end

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "event-templates:delete", fn ->
      user = current_user(conn)
      event_template = GetEventTemplate.call(id, user)

      authorize_team_editor(conn, event_template.team_id, fn ->
        {:ok, _event_template} = DeleteEventTemplate.call(id, params, user)

        conn
        |> put_flash(:info, "Event Template deleted successfully.")
        |> redirect(to: Routes.event_path(conn, :index))
      end)
    end)
  end

  # Helpers

  defp get_related_event_templates(params, user) do
    required_params = %{
      filters: %{
        user_id: user.id
      },
      paginate: true,
      preload: @preload
    }

    event_template_params = Map.merge(params, Artemis.Helpers.keys_to_strings(required_params))

    ListEventTemplates.call(event_template_params, user)
  end

  defp get_related_team_options(user) do
    types = [
      "admin",
      "editor"
    ]

    team_ids =
      user
      |> Map.get(:user_teams)
      |> Enum.filter(&Enum.member?(types, &1.type))
      |> Enum.map(& &1.team_id)

    params = %{
      filters: %{
        id: team_ids
      }
    }

    params
    |> ListTeams.call(user)
    |> Enum.map(&[key: &1.name, value: &1.id])
  end

  defp get_schedule_rules_count(conn, %Artemis.EventTemplate{} = params) do
    get_schedule_rules_count(conn, Map.from_struct(params))
  end

  defp get_schedule_rules_count(conn, params) do
    query_param = Map.get(conn.query_params, "schedule_rules_count")

    current_count =
      params
      |> Artemis.Helpers.keys_to_strings()
      |> Map.get("schedule")
      |> Artemis.Helpers.Schedule.recurrence_rules()
      |> length()

    case query_param do
      nil -> current_count
      _ -> Artemis.Helpers.to_integer(query_param)
    end
  end

  defp get_params(params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> parse_schedule_params()
  end

  defp parse_schedule_params(params) do
    encoded =
      params
      |> Map.get("schedule", %{})
      |> Map.values()
      |> Artemis.Helpers.Schedule.encode()

    has_recurrence_rules? =
      encoded
      |> Artemis.Helpers.Schedule.recurrence_rules()
      |> length()
      |> Kernel.>=(1)

    case has_recurrence_rules? do
      true -> Map.put(params, "schedule", encoded)
      false -> Map.put(params, "schedule", nil)
    end
  end
end
