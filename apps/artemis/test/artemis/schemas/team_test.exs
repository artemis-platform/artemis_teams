defmodule Artemis.TeamTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Repo
  alias Artemis.Standup
  alias Artemis.Team
  alias Artemis.TeamUser

  @preload [:standups, :team_users, :users]

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

  describe "associations - standups" do
    setup do
      team =
        :team
        |> insert
        |> with_standups

      {:ok, team: Repo.preload(team, @preload)}
    end

    test "cannot update associations through parent", %{team: team} do
      new_standup = insert(:standup, team: team)

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert length(team.standups) == 4

      {:ok, updated} =
        team
        |> Team.changeset(%{standups: [new_standup]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.standups) == 4
    end

    test "deleting association does not remove record", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.standups) == 3

      Enum.map(team.standups, &Repo.delete(&1))

      team =
        Team
        |> preload(^@preload)
        |> Repo.get(team.id)

      assert Repo.get(Team, team.id) != nil
      assert length(team.standups) == 0
    end

    test "deleting record deletes associations", %{team: team} do
      assert Repo.get(Team, team.id) != nil
      assert length(team.standups) == 3

      Enum.map(team.standups, fn standup ->
        assert Repo.get(Standup, standup.id).team_id == team.id
      end)

      Repo.delete(team)

      assert Repo.get(Team, team.id) == nil

      Enum.map(team.standups, fn standup ->
        assert Repo.get(Standup, standup.id) == nil
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
