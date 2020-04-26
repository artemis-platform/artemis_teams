defmodule ArtemisWeb.EventInstancePageTest do
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
      event_instance = insert(:event_instance)
      url = get_url(event_instance.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_instance: event_instance}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Event Questions")
    end

    test "search", %{event_instance: event_instance} do
      fill_inputs(".search-resource", %{
        query: event_instance.title
      })

      submit_search(".search-resource")

      assert visible?(event_instance.title)
    end
  end

  describe "new / create" do
    setup do
      event_instance = insert(:event_instance)
      url = get_url(event_instance.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_instance: event_instance}
    end

    test "submitting an empty form shows an error" do
      click_link("New")
      submit_form("#event-instance-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record", %{event_instance: event_instance} do
      click_link("New")

      fill_inputs("#event-instance-form", %{
        "event_instance[title]": "Test Title"
      })

      fill_select("#event-instance-form select[name=event_instance[event_instance_id]]", event_instance.id)

      submit_form("#event-instance-form")

      assert visible?("Test Title")
    end
  end

  describe "show" do
    setup do
      event_instance = insert(:event_instance)
      url = get_url(event_instance.event_template)

      Artemis.ListEventInstances.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, event_instance: event_instance}
    end

    test "record details", %{event_instance: event_instance} do
      click_link(event_instance.title)

      assert visible?(event_instance.title)
    end
  end

  describe "edit / update" do
    setup do
      event_instance = insert(:event_instance)
      url = get_url(event_instance.event_template)

      Artemis.ListEventInstances.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, event_instance: event_instance}
    end

    test "successfully updates record", %{event_instance: event_instance} do
      click_link(event_instance.title)
      click_link("Edit")

      fill_inputs("#event-instance-form", %{
        "event_instance[title]": "Updated Title"
      })

      submit_form("#event-instance-form")

      assert visible?("Updated Title")
    end
  end

  describe "delete" do
    setup do
      event_instance = insert(:event_instance)
      url = get_url(event_instance.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_instance: event_instance}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{event_instance: event_instance} do
    #   click_link(event_instance.title)
    #   click_button("Delete")
    #   accept_dialog()
    #
    #   assert current_url() == get_url(event_instance.event_template)
    #   assert not visible?(event_instance.title)
    # end
  end

  # Helpers

  defp get_url(event_template) do
    _event_instance = insert(:event_instance, event_template: event_template)

    event_instance_url(ArtemisWeb.Endpoint, :index, event_template)
  end
end
