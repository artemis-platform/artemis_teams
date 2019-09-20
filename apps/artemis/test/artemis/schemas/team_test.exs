defmodule Artemis.TeamTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.EventTemplate
  alias Artemis.Repo
  alias Artemis.Team
  alias Artemis.TeamUser

  @preload [:event_templates, :team_users, :users]

  describe "attributes - constraints" do
    test "slug must be unique" do
      existing = insert(:team)

      assert_raise Ecto.ConstraintError, fn ->
        insert(:team, slug: existing.slug)
      end
    end
  end

  describe "queries - active?" do
    test "returns false when not active" do
      team = insert(:team)

      assert Team.active?(team) == false
    end

    test "returns true when active" do
      team = insert(:team, active: true)

      assert Team.active?(team) == true
    end
  end

  describe "associations - event templates" do
    setup do
      team =
        :team
        |> insert
        |> with_event_templates

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

  describe "associations - team users" do
    setup do
      team =
        :team
        |> insert
        |> with_team_users

      {:ok, team: Repo.preload(team, @preload)}
    end

    test "cannot update associations through parent", %{team: team} do
      new_team_user = insert(:team_user, team: team)

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert length(team.team_users) == 4

      {:ok, updated} =
        team
        |> Team.changeset(%{team_users: [new_team_user]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.team_users) == 4
    end

    test "deleting association does not remove record", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.team_users) == 3

      Enum.map(team.team_users, &Repo.delete(&1))

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert Repo.get(Team, team.id) != nil
      assert length(team.team_users) == 0
    end

    test "deleting record deletes associations", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.team_users) == 3

      Enum.map(team.team_users, fn team_user ->
        assert Repo.get(TeamUser, team_user.id).team_id == team.id
      end)

      Repo.delete(team)

      assert Repo.get(Team, team.id) == nil

      Enum.map(team.team_users, fn team_user ->
        assert Repo.get(TeamUser, team_user.id) == nil
      end)
    end
  end
end
