defmodule Artemis.UpdateTeamTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateTeam

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:team)

      assert_raise Artemis.Context.Error, fn ->
        UpdateTeam.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      team = insert(:team)
      params = %{}

      updated = UpdateTeam.call!(team, params, Mock.system_user())

      assert updated.name == team.name
    end

    test "updates a record when passed valid params" do
      team = insert(:team)
      params = params_for(:team)

      updated = UpdateTeam.call!(team, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      team = insert(:team)
      params = params_for(:team)

      updated = UpdateTeam.call!(team.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:team)

      {:error, _} = UpdateTeam.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      team = insert(:team)
      params = %{}

      {:ok, updated} = UpdateTeam.call(team, params, Mock.system_user())

      assert updated.name == team.name
    end

    test "updates a record when passed valid params" do
      team = insert(:team)
      params = params_for(:team)

      {:ok, updated} = UpdateTeam.call(team, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      team = insert(:team)
      params = params_for(:team)

      {:ok, updated} = UpdateTeam.call(team.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      team = insert(:team)
      params = params_for(:team)

      {:ok, updated} = UpdateTeam.call(team, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "team:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
