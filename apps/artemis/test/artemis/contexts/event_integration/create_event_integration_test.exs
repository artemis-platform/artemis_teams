defmodule Artemis.CreateEventIntegrationTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateEventIntegration

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateEventIntegration.call!(%{}, Mock.system_user())
      end
    end

    test "creates a event_integration when passed valid params" do
      event_template = insert(:event_template)

      params = params_for(:event_integration, event_template: event_template)

      event_integration = CreateEventIntegration.call!(params, Mock.system_user())

      assert event_integration.name == params.name
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateEventIntegration.call(%{}, Mock.system_user())

      assert errors_on(changeset).integration_type == ["can't be blank"]
      assert errors_on(changeset).notification_type == ["can't be blank"]
    end

    test "creates a event_integration when passed valid params" do
      event_template = insert(:event_template)

      params = params_for(:event_integration, event_template: event_template)

      {:ok, event_integration} = CreateEventIntegration.call(params, Mock.system_user())

      assert event_integration.name == params.name
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      event_template = insert(:event_template)

      params = params_for(:event_integration, event_template: event_template)

      {:ok, event_integration} = CreateEventIntegration.call(params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "event_integration:created",
        payload: %{
          data: ^event_integration
        }
      }
    end
  end
end
