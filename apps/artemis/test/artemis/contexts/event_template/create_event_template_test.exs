defmodule Artemis.CreateEventTemplateTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateEventTemplate

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateEventTemplate.call!(%{}, Mock.system_user())
      end
    end

    test "creates a event_template when passed valid params" do
      team = insert(:team)

      params = params_for(:event_template, team: team)

      event_template = CreateEventTemplate.call!(params, Mock.system_user())

      assert event_template.title == params.title
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateEventTemplate.call(%{}, Mock.system_user())

      assert errors_on(changeset).title == ["can't be blank"]
    end

    test "creates a event_template when passed valid params" do
      team = insert(:team)

      params = params_for(:event_template, team: team)

      {:ok, event_template} = CreateEventTemplate.call(params, Mock.system_user())

      assert event_template.title == params.title
    end

    test "supports markdown" do
      team = insert(:team)

      params = params_for(:event_template, description: "# Test", team: team)

      {:ok, event_template} = CreateEventTemplate.call(params, Mock.system_user())

      assert event_template.description == params.description
      assert event_template.description_html == "<h1>Test</h1>\n"
    end

    test "converts categories string to list" do
      team = insert(:team)

      params = params_for(:event_template, categories: "one\ntwo", team: team)

      {:ok, event_template} = CreateEventTemplate.call(params, Mock.system_user())

      assert event_template.categories == ["one", "two"]
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      team = insert(:team)

      params = params_for(:event_template, team: team)

      {:ok, event_template} = CreateEventTemplate.call(params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "event_template:created",
        payload: %{
          data: ^event_template
        }
      }
    end
  end
end
