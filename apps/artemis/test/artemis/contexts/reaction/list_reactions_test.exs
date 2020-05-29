defmodule Artemis.ListReactionsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListReactions
  alias Artemis.Repo
  alias Artemis.Reaction

  setup do
    Repo.delete_all(Reaction)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no reactions exist" do
      assert ListReactions.call(Mock.system_user()) == []
    end

    test "returns existing reaction" do
      reaction = insert(:reaction)

      assert ListReactions.call(Mock.system_user()) == [reaction]
    end

    test "returns a list of reactions" do
      count = 3
      insert_list(count, :reaction)

      reactions = ListReactions.call(Mock.system_user())

      assert length(reactions) == count
    end
  end

  describe "call - params" do
    setup do
      reaction = insert(:reaction)

      {:ok, reaction: reaction}
    end

    test "filters" do
      reaction = insert(:reaction)
      insert_list(3, :reaction)

      params = %{}
      results = ListReactions.call(params, Mock.system_user())

      assert length(results) == length(Repo.all(Reaction))

      # With user belongs to association filter

      params = %{
        filters: %{
          user_id: reaction.user_id
        }
      }

      results = ListReactions.call(params, Mock.system_user())

      assert length(results) == 1
    end

    test "order" do
      insert_list(3, :reaction)

      params = %{order: "value"}
      ascending = ListReactions.call(params, Mock.system_user())

      params = %{order: "-value"}
      descending = ListReactions.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListReactions.call(params, Mock.system_user())
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
  end
end
