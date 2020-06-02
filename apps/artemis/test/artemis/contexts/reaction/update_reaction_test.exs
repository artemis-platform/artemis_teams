defmodule Artemis.UpdateReactionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateReaction

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:reaction)

      assert_raise Artemis.Context.Error, fn ->
        UpdateReaction.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      reaction = insert(:reaction)
      params = %{}

      updated = UpdateReaction.call!(reaction, params, Mock.system_user())

      assert updated.value == reaction.value
    end

    test "updates a record when passed valid params" do
      reaction = insert(:reaction)
      params = params_for(:reaction)

      updated = UpdateReaction.call!(reaction, params, Mock.system_user())

      assert updated.value == params.value
    end

    test "updates a record when passed an id and valid params" do
      reaction = insert(:reaction)
      params = params_for(:reaction)

      updated = UpdateReaction.call!(reaction.id, params, Mock.system_user())

      assert updated.value == params.value
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:reaction)

      {:error, _} = UpdateReaction.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      reaction = insert(:reaction)
      params = %{}

      {:ok, updated} = UpdateReaction.call(reaction, params, Mock.system_user())

      assert updated.value == reaction.value
    end

    test "updates a record when passed valid params" do
      reaction = insert(:reaction)
      params = params_for(:reaction)

      {:ok, updated} = UpdateReaction.call(reaction, params, Mock.system_user())

      assert updated.value == params.value
    end

    test "updates a record when passed an id and valid params" do
      reaction = insert(:reaction)
      params = params_for(:reaction)

      {:ok, updated} = UpdateReaction.call(reaction.id, params, Mock.system_user())

      assert updated.value == params.value
    end

    test "preloads associations" do
      reaction = insert(:reaction)
      params = params_for(:reaction)

      {:ok, updated} = UpdateReaction.call(reaction.id, params, Mock.system_user())

      assert updated.user != nil
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      reaction = insert(:reaction)
      params = params_for(:reaction)

      {:ok, updated} = UpdateReaction.call(reaction, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "reaction:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
