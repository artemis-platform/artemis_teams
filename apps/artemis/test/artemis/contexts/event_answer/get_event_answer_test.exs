defmodule Artemis.GetEventAnswerTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetEventAnswer

  setup do
    event_answer = insert(:event_answer)

    {:ok, event_answer: event_answer}
  end

  describe "call" do
    test "returns nil event_answer not found" do
      invalid_id = 50_000_000

      assert GetEventAnswer.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds event_answer by id", %{event_answer: event_answer} do
      assert GetEventAnswer.call(event_answer.id, Mock.system_user()).id == event_answer.id
    end

    test "finds record by keyword list", %{event_answer: event_answer} do
      assert GetEventAnswer.call([value: event_answer.value], Mock.system_user()).id == event_answer.id
    end
  end

  describe "call!" do
    test "raises an exception event_answer not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetEventAnswer.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds event_answer by id", %{event_answer: event_answer} do
      assert GetEventAnswer.call!(event_answer.id, Mock.system_user()).id == event_answer.id
    end
  end
end
