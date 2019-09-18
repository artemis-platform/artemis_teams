defmodule Artemis.DeleteTeamUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.DeleteTeamUser
  alias Artemis.TeamUser

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000

      assert_raise Artemis.Context.Error, fn ->
        DeleteTeamUser.call!(invalid_id, Mock.system_user())
      end
    end

    test "updates a record when passed valid params" do
      record = insert(:team_user)

      %TeamUser{} = DeleteTeamUser.call!(record, Mock.system_user())

      assert Repo.get(TeamUser, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:team_user)

      %TeamUser{} = DeleteTeamUser.call!(record.id, Mock.system_user())

      assert Repo.get(TeamUser, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50_000_000

      {:error, _} = DeleteTeamUser.call(invalid_id, Mock.system_user())
    end

    test "updates a record when passed valid params" do
      record = insert(:team_user)

      {:ok, _} = DeleteTeamUser.call(record, Mock.system_user())

      assert Repo.get(TeamUser, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:team_user)

      {:ok, _} = DeleteTeamUser.call(record.id, Mock.system_user())

      assert Repo.get(TeamUser, record.id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, team_user} = DeleteTeamUser.call(insert(:team_user), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "team-user:deleted",
        payload: %{
          data: ^team_user
        }
      }
    end
  end
end
