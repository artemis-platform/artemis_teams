defmodule Artemis.UpdateRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateRecognition
  alias Artemis.UserRecognition

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:recognition)

      assert_raise Artemis.Context.Error, fn ->
        UpdateRecognition.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      recognition = insert(:recognition)
      params = %{}

      updated = UpdateRecognition.call!(recognition, params, Mock.system_user())

      assert updated.description == recognition.description
    end

    test "updates a record when passed valid params" do
      recognition = insert(:recognition)
      params = params_for(:recognition)

      updated = UpdateRecognition.call!(recognition, params, Mock.system_user())

      assert updated.description == params.description
    end

    test "updates a record when passed an id and valid params" do
      recognition = insert(:recognition)
      params = params_for(:recognition)

      updated = UpdateRecognition.call!(recognition.id, params, Mock.system_user())

      assert updated.description == params.description
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:recognition)

      {:error, _} = UpdateRecognition.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      recognition = insert(:recognition)
      params = %{}

      {:ok, updated} = UpdateRecognition.call(recognition, params, Mock.system_user())

      assert updated.description == recognition.description
    end

    test "updates a record when passed valid params" do
      recognition = insert(:recognition)
      params = params_for(:recognition)

      {:ok, updated} = UpdateRecognition.call(recognition, params, Mock.system_user())

      assert updated.description == params.description
    end

    test "updates a record when passed an id and valid params" do
      recognition = insert(:recognition)
      params = params_for(:recognition)

      {:ok, updated} = UpdateRecognition.call(recognition.id, params, Mock.system_user())

      assert updated.description == params.description
    end

    test "supports markdown" do
      recognition = insert(:recognition)
      params = params_for(:recognition, description: "# Test")

      {:ok, updated} = UpdateRecognition.call(recognition.id, params, Mock.system_user())

      assert updated.description == params.description
      assert updated.description_html == "<h1>Test</h1>\n"
    end
  end

  describe "call - associations" do
    test "adds associations and updates record" do
      user_recognition = insert(:user_recognition)
      recognition = insert(:recognition)

      recognition = Repo.preload(recognition, [:user_recognitions])

      assert recognition.user_recognitions == []

      # Add Association

      params = %{
        id: recognition.id,
        description: "Updated Description",
        user_recognitions: [
          %{id: user_recognition.id}
        ]
      }

      {:ok, updated} = UpdateRecognition.call(recognition.id, params, Mock.system_user())

      assert hd(updated.user_recognitions).recognition_id == updated.id
      assert updated.description == "Updated Description"
    end

    test "removes associations when explicitly passed an empty value" do
      recognition =
        :recognition
        |> insert
        |> with_user_recognitions

      recognition = Repo.preload(recognition, [:user_recognitions])

      assert length(recognition.user_recognitions) == 3

      # Keeps existing associations if the association key is not passed

      params = %{
        id: recognition.id,
        description: "New Description"
      }

      {:ok, updated} = UpdateRecognition.call(recognition.id, params, Mock.system_user())

      assert length(updated.user_recognitions) == 3

      # Only removes associations when the association key is explicitly passed

      params = %{
        id: recognition.id,
        user_recognitions: []
      }

      {:ok, updated} = UpdateRecognition.call(recognition.id, params, Mock.system_user())

      assert length(updated.user_recognitions) == 0
    end

    test "updates associations and updates record" do
      recognition =
        :recognition
        |> insert
        |> with_user_recognitions

      recognition = Repo.preload(recognition, [:user_recognitions])
      original_user_recognition_ids = Enum.map(recognition.user_recognitions, & &1.id)

      assert length(original_user_recognition_ids) == 3

      Enum.map(original_user_recognition_ids, fn id ->
        assert Repo.get(UserRecognition, id) != nil
      end)

      # Existing associations are preserved, not regenerated, when passed an id

      params = %{
        id: recognition.id,
        user_recognitions: recognition.user_recognitions
      }

      {:ok, updated} = UpdateRecognition.call(recognition.id, params, Mock.system_user())
      updated_user_recognition_ids = Enum.map(updated.user_recognitions, & &1.id)

      assert length(updated_user_recognition_ids) == 3

      Enum.map(updated_user_recognition_ids, fn id ->
        assert Repo.get(UserRecognition, id) != nil
      end)

      assert updated_user_recognition_ids == original_user_recognition_ids

      # Existing associations are preserved, not regenerated, even when not passed an id

      without_ids =
        Enum.map(recognition.user_recognitions, fn record ->
          record
          |> Map.from_struct()
          |> Map.delete(:id)
        end)

      params = %{
        id: recognition.id,
        user_recognitions: without_ids
      }

      {:ok, updated} = UpdateRecognition.call(recognition.id, params, Mock.system_user())

      updated_user_recognition_ids = Enum.map(updated.user_recognitions, & &1.id)

      assert length(updated_user_recognition_ids) == 3

      Enum.map(updated_user_recognition_ids, fn id ->
        assert Repo.get(UserRecognition, id) != nil
      end)

      assert updated_user_recognition_ids == original_user_recognition_ids
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      recognition = insert(:recognition)
      params = params_for(:recognition)

      {:ok, updated} = UpdateRecognition.call(recognition, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "recognition:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
