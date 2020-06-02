defmodule Artemis.DeleteRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Comment
  alias Artemis.DeleteRecognition
  alias Artemis.Reaction
  alias Artemis.Recognition

  describe "access permissions" do
    setup do
      user = insert(:user)

      recognition =
        :recognition
        |> insert(created_by: user)
        |> with_user_recognitions()

      {:ok, recognition: recognition, user: user}
    end

    test "returns error with no permissions", %{recognition: recognition, user: user} do
      {:error, "Record not found"} = DeleteRecognition.call(recognition, user)
    end

    test "requires access:self permission to delete own record", %{recognition: recognition, user: user} do
      with_permission(user, "recognitions:access:self")

      {:ok, deleted} = DeleteRecognition.call(recognition, user)

      assert deleted.id == recognition.id
    end

    test "requires access:all permission to delete other records", %{user: user} do
      other_user = insert(:user)

      other_recognition =
        :recognition
        |> insert(created_by: other_user)
        |> with_user_recognitions()

      # Errors without permissions

      {:error, "Record not found"} = DeleteRecognition.call(other_recognition, user)

      # Succeeds with permissions

      with_permission(user, "recognitions:access:all")

      {:ok, deleted} = DeleteRecognition.call(other_recognition, user)

      assert deleted.id == other_recognition.id
    end
  end

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

    test "deletes associated many to many comment associations" do
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

    test "deletes associated many to many reaction associations" do
      record = insert(:recognition)
      reactions = insert_list(3, :reaction, resource_type: "Recognition", resource_id: Integer.to_string(record.id))
      _other = insert_list(2, :reaction)

      total_before =
        Reaction
        |> Repo.all()
        |> length()

      {:ok, _} = DeleteRecognition.call(record.id, Mock.system_user())

      assert Repo.get(Recognition, record.id) == nil

      total_after =
        Reaction
        |> Repo.all()
        |> length()

      assert total_after == total_before - 3
      assert Repo.get(Reaction, hd(reactions).id) == nil
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
