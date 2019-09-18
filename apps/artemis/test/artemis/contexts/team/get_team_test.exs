defmodule Artemis.GetTeamTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetTeam

  setup do
    team = insert(:team)

    {:ok, team: team}
  end

  describe "access permissions" do
    test "returns nil with no permissions" do
      user = Mock.user_without_permissions()
      team_user = insert(:team_user, user: user)
      record = team_user.team

      nil = GetTeam.call(record.id, user)
    end

    test "requires access:self permission to return own record" do
      user = Mock.user_with_permission("teams:access:associated")
      team_user = insert(:team_user, user: user)
      record = team_user.team

      assert GetTeam.call(record.id, user).id == record.id
    end

    test "requires access:all permission to return other records" do
      user = Mock.user_without_permissions()

      other_user = Artemis.Factories.insert(:user)
      other_record = insert(:team)
      insert(:team_user, team: other_record, user: other_user)

      assert GetTeam.call(other_record.id, user) == nil

      # With Permissions

      user = Mock.user_with_permission("teams:access:all")

      assert GetTeam.call(other_record.id, user).id == other_record.id
    end
  end

  describe "call" do
    test "returns nil team not found" do
      invalid_id = 50_000_000

      assert GetTeam.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds team by id", %{team: team} do
      assert GetTeam.call(team.id, Mock.system_user()) == team
    end

    test "finds user keyword list", %{team: team} do
      assert GetTeam.call([name: team.name, slug: team.slug], Mock.system_user()) == team
    end
  end

  describe "call!" do
    test "raises an exception team not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetTeam.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds team by id", %{team: team} do
      assert GetTeam.call!(team.id, Mock.system_user()) == team
    end
  end
end
