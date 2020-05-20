defmodule Artemis.DeleteRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Recognition
  alias Artemis.DeleteRecognition

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
