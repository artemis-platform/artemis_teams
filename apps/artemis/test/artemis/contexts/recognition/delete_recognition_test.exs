defmodule Artemis.DeleteRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Comment
  alias Artemis.DeleteRecognition
  alias Artemis.Recognition

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000

      assert_raise Artemis.Context.Error, fn ->
        DeleteRecognition.call!(invalid_id, Mock.system_user())
      end
    end

    test "deletes a record when passed valid params" do
      record = insert(:recognition)

      %Recognition{} = DeleteRecognition.call!(record, Mock.system_user())

      assert Repo.get(Recognition, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      record = insert(:recognition)

      %Recognition{} = DeleteRecognition.call!(record.id, Mock.system_user())

      assert Repo.get(Recognition, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50_000_000

      {:error, _} = DeleteRecognition.call(invalid_id, Mock.system_user())
    end

    test "deletes a record when passed valid params" do
      record = insert(:recognition)

      {:ok, _} = DeleteRecognition.call(record, Mock.system_user())

      assert Repo.get(Recognition, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      record = insert(:recognition)

      {:ok, _} = DeleteRecognition.call(record.id, Mock.system_user())

      assert Repo.get(Recognition, record.id) == nil
    end

    test "deletes associated many to many associations" do
      record = insert(:recognition)
      comments = insert_list(3, :comment, resource_type: "Recognition", resource_id: Integer.to_string(record.id))
      _other = insert_list(2, :comment)

      total_before =
        Comment
        |> Repo.all()
        |> length()

      {:ok, _} = DeleteRecognition.call(record.id, Mock.system_user())

      assert Repo.get(Recognition, record.id) == nil

      total_after =
        Comment
        |> Repo.all()
        |> length()

      assert total_after == total_before - 3
      assert Repo.get(Comment, hd(comments).id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, recognition} = DeleteRecognition.call(insert(:recognition), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "recognition:deleted",
        payload: %{
          data: ^recognition
        }
      }
    end
  end
end
