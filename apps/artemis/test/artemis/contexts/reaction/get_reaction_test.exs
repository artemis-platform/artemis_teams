defmodule Artemis.GetReactionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetReaction

  setup do
    user = insert(:user)

    reaction = insert(:reaction, user: user)

    {:ok, reaction: reaction, user: user}
  end

  describe "call" do
    test "returns nil reaction not found" do
      invalid_id = 50_000_000

      assert GetReaction.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds reaction by id", %{reaction: reaction} do
      assert GetReaction.call(reaction.id, Mock.system_user()) == reaction
    end

    test "finds reaction keyword list", %{reaction: reaction} do
      assert GetReaction.call([value: reaction.value], Mock.system_user()) == reaction
    end
  end

  describe "call!" do
    test "raises an exception reaction not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetReaction.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds reaction by id", %{reaction: reaction} do
      assert GetReaction.call!(reaction.id, Mock.system_user()) == reaction
    end
  end
end
