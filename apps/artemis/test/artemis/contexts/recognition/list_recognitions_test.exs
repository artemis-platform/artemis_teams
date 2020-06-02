defmodule Artemis.ListRecognitionsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListRecognitions
  alias Artemis.Repo
  alias Artemis.Recognition

  setup do
    Repo.delete_all(Recognition)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no recognitions exist" do
      assert ListRecognitions.call(Mock.system_user()) == []
    end

    test "returns existing recognition" do
      recognition = insert(:recognition)

      result = ListRecognitions.call(Mock.system_user())

      assert hd(result).id == recognition.id
    end

    test "returns a list of recognitions" do
      count = 3
      insert_list(count, :recognition)

      recognitions = ListRecognitions.call(Mock.system_user())

      assert length(recognitions) == count
    end
  end

  describe "call - params" do
    setup do
      recognition = insert(:recognition)

      {:ok, recognition: recognition}
    end

    test "order" do
      insert_list(3, :recognition)

      params = %{order: "description"}
      ascending = ListRecognitions.call(params, Mock.system_user())

      params = %{order: "-description"}
      descending = ListRecognitions.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListRecognitions.call(params, Mock.system_user())
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

    test "preload" do
      user = Mock.system_user()
      recognitions = ListRecognitions.call(user)
      recognition = hd(recognitions)

      assert !is_list(recognition.user_recognitions)
      assert recognition.user_recognitions.__struct__ == Ecto.Association.NotLoaded

      params = %{
        preload: [:user_recognitions]
      }

      recognitions = ListRecognitions.call(params, user)
      recognition = hd(recognitions)

      assert is_list(recognition.user_recognitions)
    end

    test "query - search" do
      insert(:recognition, description: "Four Six")
      insert(:recognition, description: "Four Two")
      insert(:recognition, description: "Five Six")

      user = Mock.system_user()
      recognitions = ListRecognitions.call(user)

      assert length(recognitions) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "Six"
      }

      recognitions = ListRecognitions.call(params, user)

      assert length(recognitions) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "Fou"
      }

      recognitions = ListRecognitions.call(params, user)

      assert length(recognitions) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "our"
      }

      recognitions = ListRecognitions.call(params, user)

      assert length(recognitions) == 0
    end
  end
end
