defmodule Artemis.GetEventTemplateTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetEventTemplate

  setup do
    event_template = insert(:event_template)

    {:ok, event_template: event_template}
  end

  describe "call" do
    test "returns nil event template not found" do
      invalid_id = 50_000_000

      assert GetEventTemplate.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds event template by id", %{event_template: event_template} do
      assert GetEventTemplate.call(event_template.id, Mock.system_user()) == event_template
    end

    test "finds event template keyword list", %{event_template: event_template} do
      assert GetEventTemplate.call([team_id: event_template.team.id, type: event_template.type], Mock.system_user()) == event_template
    end
  end

  describe "call!" do
    test "raises an exception event template not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetEventTemplate.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds event template by id", %{event_template: event_template} do
      assert GetEventTemplate.call!(event_template.id, Mock.system_user()) == event_template
    end
  end
end
