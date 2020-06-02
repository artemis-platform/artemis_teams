defmodule Artemis.GetUserRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetUserRecognition

  setup do
    user_recognition = insert(:user_recognition)

    {:ok, user_recognition: user_recognition}
  end

  describe "call" do
    test "returns nil user_recognition not found" do
      invalid_id = 50_000_000

      assert GetUserRecognition.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds user_recognition by id", %{user_recognition: user_recognition} do
      assert GetUserRecognition.call(user_recognition.id, Mock.system_user()).id == user_recognition.id
    end

    test "finds record by keyword list", %{user_recognition: user_recognition} do
      params = [recognition_id: user_recognition.recognition_id, user_id: user_recognition.user_id]

      assert GetUserRecognition.call(params, Mock.system_user()).id == user_recognition.id
    end
  end

  describe "call!" do
    test "raises an exception user_recognition not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetUserRecognition.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds user_recognition by id", %{user_recognition: user_recognition} do
      assert GetUserRecognition.call!(user_recognition.id, Mock.system_user()).id == user_recognition.id
    end
  end
end
