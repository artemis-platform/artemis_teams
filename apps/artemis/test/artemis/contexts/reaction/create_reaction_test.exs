defmodule Artemis.CreateReactionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateReaction

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateReaction.call!(%{}, Mock.system_user())
      end
    end

    test "creates a reaction when passed valid params" do
      params = params_for(:reaction, user: Mock.system_user())

      reaction = CreateReaction.call!(params, Mock.system_user())

      assert reaction.value == params.value
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateReaction.call(%{}, Mock.system_user())

      assert errors_on(changeset).value == ["can't be blank"]
    end

    test "creates a reaction when passed valid params" do
      params = params_for(:reaction, user: Mock.system_user())

      {:ok, reaction} = CreateReaction.call(params, Mock.system_user())

      assert reaction.value == params.value
    end

    test "preloads associations" do
      params = params_for(:reaction, user: Mock.system_user())

      {:ok, reaction} = CreateReaction.call(params, Mock.system_user())

      assert reaction.user != nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      params = params_for(:reaction, user: Mock.system_user())

      {:ok, reaction} = CreateReaction.call(params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "reaction:created",
        payload: %{
          data: ^reaction
        }
      }
    end
  end
end
