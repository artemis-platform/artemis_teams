defmodule Artemis.UserAccessTest do
  use Artemis.DataCase, async: true

  import Artemis.Factories

  alias Artemis.UserAccess

  describe "in_team?" do
    test "returns false when user does not have any teams" do
      user = insert(:user, user_teams: [])
      team = insert(:team)

      assert UserAccess.in_team?(user, team) == false
    end

    test "returns false when user is not in team" do
      user = insert(:user)
      team = insert(:team)
      other_team = insert(:team)

      insert(:user_team, team: other_team, user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team) == false
    end

    test "returns true when user is in team" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team) == true
    end

    test "returns true when passed team_id" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team.id) == true
    end
  end

  describe "team_admin?" do
    test "returns false when user does not have any teams" do
      user = insert(:user, user_teams: [])
      team = insert(:team)

      assert UserAccess.team_admin?(user, team) == false
    end

    test "returns false when user is not in team" do
      user = insert(:user)
      team = insert(:team)
      other_team = insert(:team)

      insert(:user_team, team: other_team, user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.team_admin?(user, team) == false
    end

    test "returns true when user is admin in team" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "admin", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team) == true
    end

    test "returns true when passed team_id" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "admin", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team.id) == true
    end
  end

  describe "team_editor?" do
    test "returns false when user does not have any teams" do
      user = insert(:user, user_teams: [])
      team = insert(:team)

      assert UserAccess.team_editor?(user, team) == false
    end

    test "returns false when user is not in team" do
      user = insert(:user)
      team = insert(:team)
      other_team = insert(:team)

      insert(:user_team, team: other_team, user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.team_editor?(user, team) == false
    end

    test "returns true when user is editor in team" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "editor", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team) == true
    end

    test "returns true when passed team_id" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "editor", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team.id) == true
    end
  end

  describe "team_member?" do
    test "returns false when user does not have any teams" do
      user = insert(:user, user_teams: [])
      team = insert(:team)

      assert UserAccess.team_member?(user, team) == false
    end

    test "returns false when user is not in team" do
      user = insert(:user)
      team = insert(:team)
      other_team = insert(:team)

      insert(:user_team, team: other_team, user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.team_member?(user, team) == false
    end

    test "returns true when user is member in team" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "member", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team) == true
    end

    test "returns true when passed team_id" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "member", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team.id) == true
    end
  end

  describe "team_viewer?" do
    test "returns false when user does not have any teams" do
      user = insert(:user, user_teams: [])
      team = insert(:team)

      assert UserAccess.team_viewer?(user, team) == false
    end

    test "returns false when user is not in team" do
      user = insert(:user)
      team = insert(:team)
      other_team = insert(:team)

      insert(:user_team, team: other_team, user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.team_viewer?(user, team) == false
    end

    test "returns true when user is viewer in team" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "viewer", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team) == true
    end

    test "returns true when passed team_id" do
      user = insert(:user)
      team = insert(:team)

      insert(:user_team, team: team, type: "viewer", user: user)

      user = Repo.preload(user, [:user_teams], force: true)

      assert UserAccess.in_team?(user, team.id) == true
    end
  end
end
