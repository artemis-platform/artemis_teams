defmodule Artemis.UpdateEventIntegrationTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateEventIntegration

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:event_integration)

      assert_raise Artemis.Context.Error, fn ->
        UpdateEventIntegration.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      event_integration = insert(:event_integration)
      params = %{}

      updated = UpdateEventIntegration.call!(event_integration, params, Mock.system_user())

      assert updated.name == event_integration.name
    end

    test "updates a record when passed valid params" do
      event_integration = insert(:event_integration)
      params = params_for(:event_integration)

      updated = UpdateEventIntegration.call!(event_integration, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      event_integration = insert(:event_integration)
      params = params_for(:event_integration)

      updated = UpdateEventIntegration.call!(event_integration.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:event_integration)

      {:error, _} = UpdateEventIntegration.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      event_integration = insert(:event_integration)
      params = %{}

      {:ok, updated} = UpdateEventIntegration.call(event_integration, params, Mock.system_user())

      assert updated.name == event_integration.name
    end

    test "updates a record when passed valid params" do
      event_integration = insert(:event_integration)
      params = params_for(:event_integration)

      {:ok, updated} = UpdateEventIntegration.call(event_integration, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      event_integration = insert(:event_integration)
      params = params_for(:event_integration)

      {:ok, updated} = UpdateEventIntegration.call(event_integration.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      event_integration = insert(:event_integration)
      params = params_for(:event_integration)

      {:ok, updated} = UpdateEventIntegration.call(event_integration, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "event_integration:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
