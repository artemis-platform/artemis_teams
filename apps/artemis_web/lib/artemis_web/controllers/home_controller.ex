defmodule ArtemisWeb.HomeController do
  use ArtemisWeb, :controller

  alias Artemis.ListEventTemplates
  alias Artemis.ListRecognitions
  alias Artemis.ListUserTeams

  def index(conn, params) do
    user = current_user(conn)
    recognitions = get_recognitions(params, user)

    assigns = [
      event_templates: get_related_event_templates(user),
      recognitions: recognitions,
      user_teams: get_related_user_teams(user)
    ]

    render(conn, "index.html", assigns)
  end

  # Helpers

  defp get_related_event_templates(user) do
    params = %{
      filters: %{
        user_id: user.id
      },
      preload: [:team]
    }

    ListEventTemplates.call(params, user)
  end

  defp get_related_user_teams(user) do
    params = %{
      filters: %{
        user_id: user.id
      },
      preload: [:team]
    }

    ListUserTeams.call(params, user)
  end

  defp get_recognitions(params, user) do
    recognition_params =
      params
      |> Artemis.Helpers.keys_to_strings()
      |> Map.put("paginate", true)
      |> Map.put("preload", [:created_by, :users])

    ListRecognitions.call(recognition_params, user)
  end
end
