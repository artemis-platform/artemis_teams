defmodule Artemis.GetTeamUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetTeamUser

  setup do
    team_user = insert(:team_user)

    {:ok, team_user: team_user}
  end

  describe "call" do
    test "returns nil team user not found" do
      invalid_id = 50_000_000

      assert GetTeamUser.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds team user by id", %{team_user: team_user} do
      assert GetTeamUser.call(team_user.id, Mock.system_user()) == team_user
    end

    test "finds user keyword list", %{team_user: team_user} do
      assert GetTeamUser.call([team_id: team_user.team.id, type: team_user.type], Mock.system_user()) == team_user
    end
  end

  describe "call!" do
    test "raises an exception team user not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetTeamUser.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds team user by id", %{team_user: team_user} do
      assert GetTeamUser.call!(team_user.id, Mock.system_user()) == team_user
    end
  end
end
