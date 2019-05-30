defmodule Artemis.GetStandupTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetStandup

  setup do
    standup = insert(:standup)

    {:ok, standup: standup}
  end

  describe "call" do
    test "returns nil standup not found" do
      invalid_id = 50_000_000

      assert GetStandup.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds standup by id", %{standup: standup} do
      assert GetStandup.call(standup.id, Mock.system_user()) == standup
    end

    test "finds user keyword list", %{standup: standup} do
      assert GetStandup.call([blockers: standup.blockers, date: standup.date], Mock.system_user()) == standup
    end
  end

  describe "call!" do
    test "raises an exception standup not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetStandup.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds standup by id", %{standup: standup} do
      assert GetStandup.call!(standup.id, Mock.system_user()) == standup
    end
  end
end
