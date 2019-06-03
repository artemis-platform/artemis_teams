defmodule ArtemisWeb.TeamStandupController do
  use ArtemisWeb, :controller

  alias Artemis.GetTeam
  alias Artemis.ListTeamStandups
  alias Artemis.ListStandups

  @preload []

  def index(conn, params) do
    authorize(conn, "team-standups:list", fn ->
      user = current_user(conn)
      params = Map.put(params, :paginate, true)
      team = get_team!(params, user)
      team_standups = ListTeamStandups.call(params, user)

      render(conn, "index.html", team: team, team_standups: team_standups)
    end)
  end

  def show(conn, %{"id" => id, "team_id" => team_id}) do
    authorize(conn, "team-standups:show", fn ->
      user = current_user(conn)
      team = get_team!(team_id, user)
      # TODO: implement team_id filter
      params = %{filters: %{date: id}}
      standups = ListStandups.call(params, user)

      IO.inspect standups

      render(conn, "show.html", standups: standups, team: team)
    end)
  end

  # Helpers

  defp get_team!(%{"team_id" => team_id}, user), do: get_team!(team_id, user)
  defp get_team!(id, user), do: GetTeam.call!(id, user)
end
