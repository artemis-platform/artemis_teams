defmodule ArtemisWeb.EventIntegrationPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser

  hound_session()

  describe "authentication" do
    test "requires authentication" do
      event_template = insert(:event_template)
      url = get_url(event_template)

      navigate_to(url)

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      event_integration = insert(:event_integration)
      url = get_url(event_integration.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_integration: event_integration}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Event Integrations")
    end
  end

  describe "new / create" do
    setup do
      event_integration = insert(:event_integration)
      url = get_url(event_integration.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_integration: event_integration}
    end

    test "submitting an empty form shows an error" do
      click_link("New")
      submit_form("#event-integration-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record", %{event_integration: _event_integration} do
      click_link("New")

      fill_inputs("#event-integration-form", %{
        "event_integration[name]": "Test Name"
      })

      submit_form("#event-integration-form")

      assert visible?("Test Name")
    end
  end

  describe "show" do
    setup do
      event_integration = insert(:event_integration)
      url = get_url(event_integration.event_template)

      Artemis.ListEventIntegrations.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, event_integration: event_integration}
    end

    test "record details", %{event_integration: event_integration} do
      click_link(event_integration.name)

      assert visible?(event_integration.name)
    end
  end

  describe "edit / update" do
    setup do
      event_integration = insert(:event_integration)
      url = get_url(event_integration.event_template)

      Artemis.ListEventIntegrations.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, event_integration: event_integration}
    end

    test "successfully updates record", %{event_integration: event_integration} do
      click_link(event_integration.name)
      click_link("Edit")

      fill_inputs("#event-integration-form", %{
        "event_integration[name]": "Updated Name"
      })

      submit_form("#event-integration-form")

      assert visible?("Updated Name")
    end
  end

  describe "delete" do
    setup do
      event_integration = insert(:event_integration)
      url = get_url(event_integration.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_integration: event_integration}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{event_integration: event_integration} do
    #   click_link(event_integration.name)
    #   click_button("Delete")
    #   accept_dialog()
    #
    #   assert current_url() == get_url(event_integration.event_template)
    #   assert not visible?(event_integration.name)
    # end
  end

  # Helpers

  defp get_url(event_template) do
    _event_integration = insert(:event_integration, event_template: event_template)

    event_integration_url(ArtemisWeb.Endpoint, :index, event_template)
  end
end
