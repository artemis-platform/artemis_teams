defmodule Artemis.DeleteUserTeamTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UserTeam
  alias Artemis.DeleteUserTeam

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000

      assert_raise Artemis.Context.Error, fn ->
        DeleteUserTeam.call!(invalid_id, Mock.system_user())
      end
    end

    test "deletes a record when passed valid params" do
      team = insert(:team)
      records = insert_list(3, :user_team, team: team, type: "admin")
      record = hd(records)

      %UserTeam{} = DeleteUserTeam.call!(record, Mock.system_user())

      assert Repo.get(UserTeam, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      team = insert(:team)
      records = insert_list(3, :user_team, team: team, type: "admin")
      record = hd(records)

      %UserTeam{} = DeleteUserTeam.call!(record.id, Mock.system_user())

      assert Repo.get(UserTeam, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50_000_000

      {:error, _} = DeleteUserTeam.call(invalid_id, Mock.system_user())
    end

    test "deletes a record when passed valid params" do
      team = insert(:team)
      records = insert_list(3, :user_team, team: team, type: "admin")
      record = hd(records)

      {:ok, _} = DeleteUserTeam.call(record, Mock.system_user())

      assert Repo.get(UserTeam, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      team = insert(:team)
      records = insert_list(3, :user_team, team: team, type: "admin")
      record = hd(records)

      {:ok, _} = DeleteUserTeam.call(record.id, Mock.system_user())

      assert Repo.get(UserTeam, record.id) == nil
    end

    test "returns an error if user is last admin on team" do
      team = insert(:team)
      record = insert(:user_team, team: team, type: "admin")

      {:error, message} = DeleteUserTeam.call(record.id, Mock.system_user())

      assert message == "A team must have at least one admin"
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      team = insert(:team)
      records = insert_list(3, :user_team, team: team, type: "admin")
      record = hd(records)

      {:ok, user_team} = DeleteUserTeam.call(record, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "user-team:deleted",
        payload: %{
          data: ^user_team
        }
      }
    end
  end
end
