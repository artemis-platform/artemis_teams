defmodule Artemis.CreateStandupTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateStandup

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateStandup.call!(%{}, Mock.system_user())
      end
    end

    test "creates a standup when passed valid params" do
      params = params_for(:standup)

      standup = CreateStandup.call!(params, Mock.system_user())

      assert standup.date == params.date
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateStandup.call(%{}, Mock.system_user())

      assert errors_on(changeset).date == ["can't be blank"]
    end

    test "creates a standup when passed valid params" do
      params = params_for(:standup)

      {:ok, standup} = CreateStandup.call(params, Mock.system_user())

      assert standup.date == params.date
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, standup} = CreateStandup.call(params_for(:standup), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "standup:created",
        payload: %{
          data: ^standup
        }
      }
    end
  end
end
