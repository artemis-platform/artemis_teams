defmodule Artemis.CreateEventAnswerTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateEventAnswer

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateEventAnswer.call!(%{}, Mock.system_user())
      end
    end

    test "creates a event_answer when passed valid params" do
      event_question = insert(:event_question)
      user = insert(:user)

      params = params_for(:event_answer, event_question: event_question, user: user)

      event_answer = CreateEventAnswer.call!(params, Mock.system_user())

      assert event_answer.value == params.value
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateEventAnswer.call(%{}, Mock.system_user())

      assert errors_on(changeset).value == ["can't be blank"]
    end

    test "creates a event_answer when passed valid params" do
      event_question = insert(:event_question)
      user = insert(:user)

      params = params_for(:event_answer, event_question: event_question, user: user)

      {:ok, event_answer} = CreateEventAnswer.call(params, Mock.system_user())

      assert event_answer.value == params.value
    end

    test "supports markdown" do
      event_question = insert(:event_question)
      user = insert(:user)

      params = params_for(:event_answer, value: "**bold**", event_question: event_question, user: user)

      {:ok, event_answer} = CreateEventAnswer.call(params, Mock.system_user())

      assert event_answer.value == params.value
      assert event_answer.value_html == "<p><strong>bold</strong></p>\n"
    end

    test "supports number values for numeric types" do
      event_question = insert(:event_question)
      user = insert(:user)

      # Text Type

      params = params_for(:event_answer, type: "text", value: "0.75", event_question: event_question, user: user)

      {:ok, event_answer} = CreateEventAnswer.call(params, Mock.system_user())

      assert event_answer.value == params.value
      assert event_answer.value_number == nil

      # Numeric Type - With Valid Float Value

      params = params_for(:event_answer, type: "number", value: "0.7531", event_question: event_question, user: user)

      {:ok, event_answer} = CreateEventAnswer.call(params, Mock.system_user())

      assert event_answer.value == params.value
      assert event_answer.value_number == Decimal.from_float(0.7531)

      # Numeric Type - With Valid Integer Value

      params = params_for(:event_answer, type: "number", value: "87", event_question: event_question, user: user)

      {:ok, event_answer} = CreateEventAnswer.call(params, Mock.system_user())

      assert event_answer.value == params.value
      assert event_answer.value_number == Decimal.new(87)

      # Numeric Type - With Invalid Value

      params = params_for(:event_answer, type: "number", value: "INVALID", event_question: event_question, user: user)

      {:error, changeset} = CreateEventAnswer.call(params, Mock.system_user())

      assert errors_on(changeset).value_number == ["is invalid"]
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      event_question = insert(:event_question)
      user = insert(:user)

      params = params_for(:event_answer, event_question: event_question, user: user)

      {:ok, event_answer} = CreateEventAnswer.call(params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "event-answer:created",
        payload: %{
          data: ^event_answer
        }
      }
    end
  end
end
