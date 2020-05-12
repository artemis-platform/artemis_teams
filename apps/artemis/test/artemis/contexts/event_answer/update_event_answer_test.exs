defmodule Artemis.UpdateEventAnswerTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateEventAnswer

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:event_answer)

      assert_raise Artemis.Context.Error, fn ->
        UpdateEventAnswer.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      event_answer = insert(:event_answer)
      params = %{}

      updated = UpdateEventAnswer.call!(event_answer, params, Mock.system_user())

      assert updated.value == event_answer.value
    end

    test "updates a record when passed valid params" do
      event_answer = insert(:event_answer)
      params = params_for(:event_answer)

      updated = UpdateEventAnswer.call!(event_answer, params, Mock.system_user())

      assert updated.value == params.value
    end

    test "updates a record when passed an id and valid params" do
      event_answer = insert(:event_answer)
      params = params_for(:event_answer)

      updated = UpdateEventAnswer.call!(event_answer.id, params, Mock.system_user())

      assert updated.value == params.value
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:event_answer)

      {:error, _} = UpdateEventAnswer.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      event_answer = insert(:event_answer)
      params = %{}

      {:ok, updated} = UpdateEventAnswer.call(event_answer, params, Mock.system_user())

      assert updated.value == event_answer.value
    end

    test "updates a record when passed valid params" do
      event_answer = insert(:event_answer)
      params = params_for(:event_answer)

      {:ok, updated} = UpdateEventAnswer.call(event_answer, params, Mock.system_user())

      assert updated.value == params.value
    end

    test "updates a record when passed an id and valid params" do
      event_answer = insert(:event_answer)
      params = params_for(:event_answer)

      {:ok, updated} = UpdateEventAnswer.call(event_answer.id, params, Mock.system_user())

      assert updated.value == params.value
    end

    test "supports markdown" do
      event_answer = insert(:event_answer)
      params = params_for(:event_answer, value: "**bold**")

      {:ok, updated} = UpdateEventAnswer.call(event_answer.id, params, Mock.system_user())

      assert updated.value == params.value
      assert updated.value_html == "<p><strong>bold</strong></p>\n"
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      event_answer = insert(:event_answer)
      params = params_for(:event_answer)

      {:ok, updated} = UpdateEventAnswer.call(event_answer, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "event-answer:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
