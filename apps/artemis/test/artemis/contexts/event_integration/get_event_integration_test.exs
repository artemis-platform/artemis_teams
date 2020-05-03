defmodule Artemis.GetEventIntegrationTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetEventIntegration

  setup do
    event_integration = insert(:event_integration)

    {:ok, event_integration: event_integration}
  end

  describe "call" do
    test "returns nil event_integration not found" do
      invalid_id = 50_000_000

      assert GetEventIntegration.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds event_integration by id", %{event_integration: event_integration} do
      assert GetEventIntegration.call(event_integration.id, Mock.system_user()).id == event_integration.id
    end

    test "finds record by keyword list", %{event_integration: event_integration} do
      assert GetEventIntegration.call([name: event_integration.name], Mock.system_user()).id == event_integration.id
    end
  end

  describe "call!" do
    test "raises an exception event_integration not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetEventIntegration.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds event_integration by id", %{event_integration: event_integration} do
      assert GetEventIntegration.call!(event_integration.id, Mock.system_user()).id == event_integration.id
    end
  end
end
