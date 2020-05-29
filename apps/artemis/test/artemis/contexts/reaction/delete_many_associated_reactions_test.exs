defmodule Artemis.DeleteManyAssociatedReactionsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Reaction
  alias Artemis.DeleteManyAssociatedReactions

  describe "call!" do
    test "raises an exception record on failure" do
      assert_raise Ecto.Query.CastError, fn ->
        DeleteManyAssociatedReactions.call!(:invalid_value, Mock.system_user())
      end
    end

    test "succeeds if record has no reactions" do
      record = insert(:wiki_page)

      result = DeleteManyAssociatedReactions.call!("WikiPage", record.id, Mock.system_user())

      assert result.total == 0
    end

    test "deletes associated reactions when passed valid resource type and resource id" do
      record = insert(:wiki_page)
      reactions = insert_list(3, :reaction, resource_id: Integer.to_string(record.id), resource_type: "WikiPage")

      result = DeleteManyAssociatedReactions.call!("WikiPage", record.id, Mock.system_user())

      assert result.total == 3
      assert Repo.get(Reaction, hd(reactions).id) == nil
    end
  end

  describe "call" do
    test "succeeds if record has no reactions" do
      record = insert(:wiki_page)

      {:ok, result} = DeleteManyAssociatedReactions.call("WikiPage", record.id, Mock.system_user())

      assert result.total == 0
    end

    test "deletes associated reactions when passed valid resource type and resource id" do
      record = insert(:wiki_page)
      reactions = insert_list(3, :reaction, resource_id: Integer.to_string(record.id), resource_type: "WikiPage")

      {:ok, result} = DeleteManyAssociatedReactions.call("WikiPage", record.id, Mock.system_user())

      assert result.total == 3
      assert Repo.get(Reaction, hd(reactions).id) == nil
    end

    test "succeeds associated reactions when passed valid resource type" do
      reactions = insert_list(3, :reaction, resource_type: "WikiPage")

      {:ok, result} = DeleteManyAssociatedReactions.call("WikiPage", Mock.system_user())

      assert result.total == 3
      assert Repo.get(Reaction, hd(reactions).id) == nil
    end
  end
end
