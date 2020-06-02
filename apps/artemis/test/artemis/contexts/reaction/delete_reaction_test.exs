defmodule Artemis.DeleteReactionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Reaction
  alias Artemis.DeleteReaction

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000

      assert_raise Artemis.Context.Error, fn ->
        DeleteReaction.call!(invalid_id, Mock.system_user())
      end
    end

    test "deletes a record when passed valid params" do
      record = insert(:reaction)

      %Reaction{} = DeleteReaction.call!(record, Mock.system_user())

      assert Repo.get(Reaction, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      record = insert(:reaction)

      %Reaction{} = DeleteReaction.call!(record.id, Mock.system_user())

      assert Repo.get(Reaction, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50_000_000

      {:error, _} = DeleteReaction.call(invalid_id, Mock.system_user())
    end

    test "deletes a record when passed valid params" do
      record = insert(:reaction)

      {:ok, _} = DeleteReaction.call(record, Mock.system_user())

      assert Repo.get(Reaction, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      record = insert(:reaction)

      {:ok, _} = DeleteReaction.call(record.id, Mock.system_user())

      assert Repo.get(Reaction, record.id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, reaction} = DeleteReaction.call(insert(:reaction), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "reaction:deleted",
        payload: %{
          data: ^reaction
        }
      }
    end
  end
end
