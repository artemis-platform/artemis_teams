defmodule Artemis.CreateRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateRecognition

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateRecognition.call!(%{}, Mock.system_user())
      end
    end

    test "creates a recognition when passed valid params" do
      params = params_for(:recognition)

      recognition = CreateRecognition.call!(params, Mock.system_user())

      assert recognition.description == params.description
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateRecognition.call(%{}, Mock.system_user())

      assert errors_on(changeset).description == ["can't be blank"]
    end

    test "creates a recognition when passed valid params" do
      params = params_for(:recognition)

      {:ok, recognition} = CreateRecognition.call(params, Mock.system_user())

      assert recognition.description == params.description
    end

    test "creates recognition with associations" do
      user1 = insert(:user)
      user2 = insert(:user)

      params =
        :recognition
        |> params_for
        |> Map.put(:user_recognitions, [
          params_for(:user_recognition, user: user1),
          params_for(:user_recognition, user: user2)
        ])

      {:ok, recognition} = CreateRecognition.call(params, Mock.system_user())

      assert recognition.description == params.description
      assert length(recognition.user_recognitions) == 2
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, recognition} = CreateRecognition.call(params_for(:recognition), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "recognition:created",
        payload: %{
          data: ^recognition
        }
      }
    end
  end
end
