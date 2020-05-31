defmodule ArtemisWeb.HomeController do
  use ArtemisWeb, :controller

  alias Artemis.ListEventTemplates
  alias Artemis.ListRecognitions
  alias Artemis.ListUserTeams

  def index(conn, _params) do
    user = current_user(conn)

    assigns = [
      event_templates: get_related_event_templates(user),
      recognition_totals: get_recognition_totals(user),
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

  defp get_recognition_totals(user) do
    params = %{
      count: true
    }

    all =
      params
      |> ListRecognitions.call(user)
      |> hd()
      |> Map.get(:count)

    # From User

    params = %{
      count: true,
      filters: %{
        created_by_id: user.id
      }
    }

    from_user =
      params
      |> ListRecognitions.call(user)
      |> hd()
      |> Map.get(:count)

    # To User

    params = %{
      count: true,
      filters: %{
        user_id: user.id
      }
    }

    to_user =
      params
      |> ListRecognitions.call(user)
      |> hd()
      |> Map.get(:count)

    %{
      all: all,
      from_user: from_user,
      to_user: to_user
    }
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
