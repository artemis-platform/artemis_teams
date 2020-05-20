defmodule Artemis.GetRecognitionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetRecognition

  setup do
    recognition = insert(:recognition)
    insert(:user, recognitions: [recognition])

    {:ok, recognition: recognition}
  end

  describe "call" do
    test "returns nil recognition not found" do
      invalid_id = 50_000_000

      assert GetRecognition.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds recognition by id", %{recognition: recognition} do
      assert GetRecognition.call(recognition.id, Mock.system_user()).id == recognition.id
    end

    test "finds record by keyword list", %{recognition: recognition} do
      assert GetRecognition.call([description: recognition.description], Mock.system_user()).id == recognition.id
    end
  end

  describe "call - options" do
    test "preload", %{recognition: recognition} do
      values = [
        description: recognition.description
      ]

      options = [
        preload: [:users]
      ]

      recognition = GetRecognition.call(values, Mock.system_user(), options)

      assert is_list(recognition.users)
    end
  end

  describe "call!" do
    test "raises an exception recognition not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetRecognition.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds recognition by id", %{recognition: recognition} do
      assert GetRecognition.call!(recognition.id, Mock.system_user()).id == recognition.id
    end
  end
end
