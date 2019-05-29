defmodule Artemis.GetTeamTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetTeam

  setup do
    team = insert(:team)

    {:ok, team: team}
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
