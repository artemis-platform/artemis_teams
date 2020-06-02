defmodule Artemis.CreateUserRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateUserRecognition

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Postgrex.Error, fn ->
        CreateUserRecognition.call!(%{}, Mock.system_user())
      end
    end

    test "creates a user_recognition when passed valid params" do
      user = insert(:user)
      recognition = insert(:recognition)

      params = params_for(:user_recognition, recognition: recognition, user: user)

      user_recognition = CreateUserRecognition.call!(params, Mock.system_user())

      assert user_recognition.recognition_id == params.recognition_id
    end
  end

  describe "call" do
    test "raises an error when params are empty" do
      assert_raise Postgrex.Error, fn ->
        CreateUserRecognition.call!(%{}, Mock.system_user())
      end
    end

    test "creates a user_recognition when passed valid params" do
      user = insert(:user)
      recognition = insert(:recognition)

      params = params_for(:user_recognition, recognition: recognition, user: user)

      {:ok, user_recognition} = CreateUserRecognition.call(params, Mock.system_user())

      assert user_recognition.recognition_id == params.recognition_id
      assert user_recognition.user_id == params.user_id
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      user = insert(:user)
      recognition = insert(:recognition)

      params = params_for(:user_recognition, recognition: recognition, user: user)

      {:ok, user_recognition} = CreateUserRecognition.call(params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "user-recognition:created",
        payload: %{
          data: ^user_recognition
        }
      }
    end
  end
end
