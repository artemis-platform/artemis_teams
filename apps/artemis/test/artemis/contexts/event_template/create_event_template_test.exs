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

    test "creates a event template when passed valid params" do
      params = params_for(:event_template)

      event_template = CreateEventTemplate.call!(params, Mock.system_user())

      assert event_template.type == params.type
    end

    test "creates slug from name if not passed as a param" do
      params = params_for(:event_template, slug: "passed-slug")

      event_template = CreateEventTemplate.call!(params, Mock.system_user())

      assert event_template.slug == "passed-slug"

      # When slug is not passed

      params = params_for(:event_template, name: "Passed Name", slug: nil)

      event_template = CreateEventTemplate.call!(params, Mock.system_user())

      assert event_template.slug == "passed-name"
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateEventTemplate.call(%{}, Mock.system_user())

      assert errors_on(changeset).type == ["can't be blank"]
    end

    test "creates a event template when passed valid params" do
      params = params_for(:event_template)

      {:ok, event_template} = CreateEventTemplate.call(params, Mock.system_user())

      assert event_template.type == params.type
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, event_template} = CreateEventTemplate.call(params_for(:event_template), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "event-template:created",
        payload: %{
          data: ^event_template
        }
      }
    end
  end
end
