defmodule Artemis.ListStandupsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListStandups
  alias Artemis.Repo
  alias Artemis.Standup

  setup do
    Repo.delete_all(Standup)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no standups exist" do
      assert ListStandups.call(Mock.system_user()) == []
    end

    test "returns existing standup" do
      standup = insert(:standup)

      assert ListStandups.call(Mock.system_user()) == [standup]
    end

    test "returns a list of standups" do
      count = 3
      insert_list(count, :standup)

      standups = ListStandups.call(Mock.system_user())

      assert length(standups) == count
    end
  end

  describe "call - params" do
    setup do
      standup = insert(:standup)

      {:ok, standup: standup}
    end

    test "order" do
      insert_list(3, :standup)

      params = %{order: "blockers"}
      ascending = ListStandups.call(params, Mock.system_user())

      params = %{order: "-blockers"}
      descending = ListStandups.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListStandups.call(params, Mock.system_user())
        |> Map.from_struct()
        |> Map.keys()

      pagination_keys = [
        :entries,
        :page_number,
        :page_size,
        :total_entries,
        :total_pages
      ]

      assert response_keys == pagination_keys
    end

    test "query - search" do
      insert(:standup, blockers: "Four Six", past: "four-six")
      insert(:standup, blockers: "Four Two", past: "four-two")
      insert(:standup, blockers: "Five Six", past: "five-six")

      user = Mock.system_user()
      standups = ListStandups.call(user)

      assert length(standups) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "Six"
      }

      standups = ListStandups.call(params, user)

      assert length(standups) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "four-"
      }

      standups = ListStandups.call(params, user)

      assert length(standups) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "our"
      }

      standups = ListStandups.call(params, user)

      assert length(standups) == 0
    end
  end
end
