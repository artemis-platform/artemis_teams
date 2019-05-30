defmodule Artemis.DeleteStandupTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Standup
  alias Artemis.DeleteStandup

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000

      assert_raise Artemis.Context.Error, fn ->
        DeleteStandup.call!(invalid_id, Mock.system_user())
      end
    end

    test "updates a record when passed valid params" do
      record = insert(:standup)

      %Standup{} = DeleteStandup.call!(record, Mock.system_user())

      assert Repo.get(Standup, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:standup)

      %Standup{} = DeleteStandup.call!(record.id, Mock.system_user())

      assert Repo.get(Standup, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50_000_000

      {:error, _} = DeleteStandup.call(invalid_id, Mock.system_user())
    end

    test "updates a record when passed valid params" do
      record = insert(:standup)

      {:ok, _} = DeleteStandup.call(record, Mock.system_user())

      assert Repo.get(Standup, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:standup)

      {:ok, _} = DeleteStandup.call(record.id, Mock.system_user())

      assert Repo.get(Standup, record.id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, standup} = DeleteStandup.call(insert(:standup), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "standup:deleted",
        payload: %{
          data: ^standup
        }
      }
    end
  end
end
