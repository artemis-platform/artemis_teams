defmodule Artemis.TeamTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.EventTemplate
  alias Artemis.Project
  alias Artemis.Repo
  alias Artemis.Team
  alias Artemis.UserTeam

  @preload [:event_templates, :projects, :user_teams, :users]

  describe "associations - event templates" do
    setup do
      team = insert(:team)

      insert_list(3, :event_template, team: team)

      {:ok, team: Repo.preload(team, @preload)}
    end

    test "cannot update associations through parent", %{team: team} do
      new_event_template = insert(:event_template, team: team)

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert length(team.event_templates) == 4

      {:ok, updated} =
        team
        |> Team.changeset(%{event_templates: [new_event_template]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.event_templates) == 4
    end

    test "deleting association does not remove record", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.event_templates) == 3

      Enum.map(team.event_templates, &Repo.delete(&1))

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert Repo.get(Team, team.id) != nil
      assert length(team.event_templates) == 0
    end

    test "deleting record deletes associations", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.event_templates) == 3

      Enum.map(team.event_templates, fn event_template ->
        assert Repo.get(EventTemplate, event_template.id).team_id == team.id
      end)

      Repo.delete(team)

      assert Repo.get(Team, team.id) == nil

      Enum.map(team.event_templates, fn event_template ->
        assert Repo.get(EventTemplate, event_template.id) == nil
      end)
    end
  end

  describe "associations - projects" do
    setup do
      team = insert(:team)

      insert_list(3, :project, team: team)

      {:ok, team: Repo.preload(team, @preload)}
    end

    test "cannot update associations through parent", %{team: team} do
      new_project = insert(:project, team: team)

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert length(team.projects) == 4

      {:ok, updated} =
        team
        |> Team.changeset(%{projects: [new_project]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.projects) == 4
    end

    test "deleting association does not remove record", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.projects) == 3

      Enum.map(team.projects, &Repo.delete(&1))

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert Repo.get(Team, team.id) != nil
      assert length(team.projects) == 0
    end

    test "deleting record deletes associations", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.projects) == 3

      Enum.map(team.projects, fn project ->
        assert Repo.get(Project, project.id).team_id == team.id
      end)

      Repo.delete(team)

      assert Repo.get(Team, team.id) == nil

      Enum.map(team.projects, fn project ->
        assert Repo.get(Project, project.id) == nil
      end)
    end
  end

  describe "associations - user teams" do
    setup do
      team = insert(:team)

      insert_list(3, :user_team, team: team)

      {:ok, team: Repo.preload(team, @preload)}
    end

    test "update associations", %{team: team} do
      new_user = insert(:user)

      assert length(team.user_teams) == 3

      {:ok, updated} =
        team
        |> Team.associations_changeset(%{user_teams: [%{team_id: team.id, user_id: new_user.id}]})
        |> Repo.update()

      assert length(updated.user_teams) == 1
      assert hd(updated.user_teams).user_id == new_user.id
    end

    test "deleting association does not remove record", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.user_teams) == 3

      Enum.map(team.user_teams, &Repo.delete(&1))

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert Repo.get(Team, team.id) != nil
      assert length(team.user_teams) == 0
    end

    test "deleting record removes associations", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.user_teams) == 3

      Repo.delete(team)

      assert Repo.get(Team, team.id) == nil

      Enum.map(team.user_teams, fn user_team ->
        assert Repo.get(UserTeam, user_team.id) == nil
      end)
    end
  end
end
