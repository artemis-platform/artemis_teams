defmodule ArtemisWeb.HomeController do
  use ArtemisWeb, :controller

  alias Artemis.ListEventTemplates
  alias Artemis.ListUserTeams

  def index(conn, _params) do
    user = current_user(conn)

    assigns = [
      event_templates: get_related_event_templates(user),
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
end
