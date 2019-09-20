defmodule ArtemisWeb.EventTemplatePageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser

  hound_session()

  defp get_url(team), do: team_event_template_url(ArtemisWeb.Endpoint, :index, team)

  describe "authentication" do
    test "requires authentication" do
      event_template = insert(:event_template)

      navigate_to(get_url(event_template.team))

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      event_template = insert(:event_template)

      browser_sign_in()
      navigate_to(get_url(event_template.team))

      {:ok, event_template: event_template}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Event Templates")
    end
  end

  describe "new / create" do
    setup do
      event_template = insert(:event_template)

      browser_sign_in()
      navigate_to(get_url(event_template.team))

      {:ok, []}
    end

    test "submitting an empty form succeeds with the defaults" do
      click_link("New")

      submit_form("#event-template-form")

      assert visible?("Standup")
    end

    test "successfully creates a new record" do
      click_link("New")

      fill_enhanced_select("#event-template-form .field-type", "Standup")

      submit_form("#event-template-form")

      assert visible?("Standup")
    end
  end

  describe "show" do
    setup do
      event_template = insert(:event_template)

      browser_sign_in()
      navigate_to(get_url(event_template.team))

      {:ok, event_template: event_template}
    end

    test "record details", %{event_template: event_template} do
      click_link(event_template.name)

      assert visible?(event_template.team.name)
      assert visible?(event_template.type)
      assert visible?(event_template.name)
    end
  end

  describe "edit / update" do
    setup do
      event_template = insert(:event_template)

      browser_sign_in()
      navigate_to(get_url(event_template.team))

      {:ok, event_template: event_template}
    end

    test "successfully updates record", %{event_template: event_template} do
      click_link(event_template.name)
      click_link("Edit")

      fill_enhanced_select("#event-template-form .field-type", "Standup")

      submit_form("#event-template-form")

      assert visible?("Standup")
    end
  end

  describe "delete" do
    setup do
      event_template = insert(:event_template)

      browser_sign_in()
      navigate_to(get_url(event_template.team))

      {:ok, event_template: event_template}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{event_template: event_template} do
    #   click_link(event_template.slug)
    #   click_button("Remove")
    #   accept_dialog()

    #   assert current_url() == get_url(event_template.team)
    #   assert not visible?(event_template.slug)
    # end
  end
end
