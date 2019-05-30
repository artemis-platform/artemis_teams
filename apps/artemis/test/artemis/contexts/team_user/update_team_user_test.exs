defmodule Artemis.UpdateTeamUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateTeamUser

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:team_user)

      assert_raise Artemis.Context.Error, fn ->
        UpdateTeamUser.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      team_user = insert(:team_user)
      params = %{}

      updated = UpdateTeamUser.call!(team_user, params, Mock.system_user())

      assert updated.type == team_user.type
    end

    test "updates a record when passed valid params" do
      team_user = insert(:team_user)
      params = params_for(:team_user)

      updated = UpdateTeamUser.call!(team_user, params, Mock.system_user())

      assert updated.type == params.type
    end

    test "updates a record when passed an id and valid params" do
      team_user = insert(:team_user)
      params = params_for(:team_user)

      updated = UpdateTeamUser.call!(team_user.id, params, Mock.system_user())

      assert updated.type == params.type
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:team_user)

      {:error, _} = UpdateTeamUser.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      team_user = insert(:team_user)
      params = %{}

      {:ok, updated} = UpdateTeamUser.call(team_user, params, Mock.system_user())

      assert updated.type == team_user.type
    end

    test "updates a record when passed valid params" do
      team_user = insert(:team_user)
      params = params_for(:team_user)

      {:ok, updated} = UpdateTeamUser.call(team_user, params, Mock.system_user())

      assert updated.type == params.type
    end

    test "updates a record when passed an id and valid params" do
      team_user = insert(:team_user)
      params = params_for(:team_user)

      {:ok, updated} = UpdateTeamUser.call(team_user.id, params, Mock.system_user())

      assert updated.type == params.type
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      team_user = insert(:team_user)
      params = params_for(:team_user)

      {:ok, updated} = UpdateTeamUser.call(team_user, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "team-user:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
