defmodule Artemis.UpdateStandupTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateStandup

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:standup)

      assert_raise Artemis.Context.Error, fn ->
        UpdateStandup.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      standup = insert(:standup)
      params = %{}

      updated = UpdateStandup.call!(standup, params, Mock.system_user())

      assert updated.date == standup.date
    end

    test "updates a record when passed valid params" do
      standup = insert(:standup)
      params = params_for(:standup)

      updated = UpdateStandup.call!(standup, params, Mock.system_user())

      assert updated.date == params.date
    end

    test "updates a record when passed an id and valid params" do
      standup = insert(:standup)
      params = params_for(:standup)

      updated = UpdateStandup.call!(standup.id, params, Mock.system_user())

      assert updated.date == params.date
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:standup)

      {:error, _} = UpdateStandup.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      standup = insert(:standup)
      params = %{}

      {:ok, updated} = UpdateStandup.call(standup, params, Mock.system_user())

      assert updated.date == standup.date
    end

    test "updates a record when passed valid params" do
      standup = insert(:standup)
      params = params_for(:standup)

      {:ok, updated} = UpdateStandup.call(standup, params, Mock.system_user())

      assert updated.date == params.date
    end

    test "updates a record when passed an id and valid params" do
      standup = insert(:standup)
      params = params_for(:standup)

      {:ok, updated} = UpdateStandup.call(standup.id, params, Mock.system_user())

      assert updated.date == params.date
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      standup = insert(:standup)
      params = params_for(:standup)

      {:ok, updated} = UpdateStandup.call(standup, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "standup:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
