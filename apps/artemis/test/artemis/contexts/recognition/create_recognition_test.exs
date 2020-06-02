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
      params = get_params()

      recognition = CreateRecognition.call!(params, Mock.system_user())

      assert recognition.description == params.description
    end

    test "supports markdown" do
      params = get_params(description: "# Test")

      {:ok, recognition} = CreateRecognition.call(params, Mock.system_user())

      assert recognition.description == params.description
      assert recognition.description_html == "<h1>Test</h1>\n"
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateRecognition.call(%{}, Mock.system_user())

      assert errors_on(changeset).description == ["can't be blank"]
    end

    test "creates a recognition when passed valid params" do
      params = get_params()

      {:ok, recognition} = CreateRecognition.call(params, Mock.system_user())

      assert recognition.description == params.description
    end

    test "creates recognition with associations" do
      user1 = insert(:user)
      user2 = insert(:user)

      params =
        Map.put(get_params(), :user_recognitions, [
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

      {:ok, recognition} = CreateRecognition.call(get_params(), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "recognition:created",
        payload: %{
          data: ^recognition
        }
      }
    end
  end

  # Helpers

  defp get_params(options \\ []) do
    default_user_recognitions = [
      %{user_id: insert(:user).id}
    ]

    :recognition
    |> params_for(options)
    |> Map.put(:created_by_id, Mock.system_user().id)
    |> Map.put(:user_recognitions, default_user_recognitions)
  end
end
