defmodule Artemis.DeleteEventAnswerTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Comment
  alias Artemis.EventAnswer
  alias Artemis.DeleteEventAnswer

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000

      assert_raise Artemis.Context.Error, fn ->
        DeleteEventAnswer.call!(invalid_id, Mock.system_user())
      end
    end

    test "deletes a record when passed valid params" do
      record = insert(:event_answer)

      %EventAnswer{} = DeleteEventAnswer.call!(record, Mock.system_user())

      assert Repo.get(EventAnswer, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      record = insert(:event_answer)

      %EventAnswer{} = DeleteEventAnswer.call!(record.id, Mock.system_user())

      assert Repo.get(EventAnswer, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50_000_000

      {:error, _} = DeleteEventAnswer.call(invalid_id, Mock.system_user())
    end

    test "deletes a record when passed valid params" do
      record = insert(:event_answer)

      {:ok, _} = DeleteEventAnswer.call(record, Mock.system_user())

      assert Repo.get(EventAnswer, record.id) == nil
    end

    test "deletes a record when passed an id and valid params" do
      record = insert(:event_answer)

      {:ok, _} = DeleteEventAnswer.call(record.id, Mock.system_user())

      assert Repo.get(EventAnswer, record.id) == nil
    end

    test "deletes associated associations" do
      record = insert(:event_answer)
      comments = insert_list(3, :comment, resource_type: "EventAnswer", resource_id: Integer.to_string(record.id))
      _other = insert_list(2, :comment)

      total_before =
        Comment
        |> Repo.all()
        |> length()

      {:ok, _} = DeleteEventAnswer.call(record.id, Mock.system_user())

      assert Repo.get(EventAnswer, record.id) == nil

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

      {:ok, event_answer} = DeleteEventAnswer.call(insert(:event_answer), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "event-answer:deleted",
        payload: %{
          data: ^event_answer
        }
      }
    end
  end
end
