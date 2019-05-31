defmodule ArtemisWeb.StandupPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  alias ArtemisWeb.Mock

  @moduletag :browser

  hound_session()

  def url(), do: standup_url(ArtemisWeb.Endpoint, :index)

  describe "authentication" do
    test "requires authentication" do
      navigate_to(url())

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      standup = insert(:standup)

      browser_sign_in()
      navigate_to(url())

      {:ok, standup: standup}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Standups")
    end

    test "search", %{standup: standup} do
      fill_inputs(".search-resource", %{
        query: String.slice(standup.blockers, 0..10)
      })

      submit_search(".search-resource")

      assert visible?(standup.blockers)
    end
  end

  describe "new / create" do
    setup do
      user = Mock.system_user()
      team_user = insert(:team_user, user: user)

      browser_sign_in()
      navigate_to(url())

      {:ok, team: team_user.team}
    end

    test "submitting an empty form shows an error" do
      click_link("New")
      submit_form("#standup-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record", %{team: team} do
      click_link("New")

      fill_enhanced_select("#standup-form .field-team-id", team.name)

      fill_inputs("#standup-form", %{
        "standup[blockers]": "Test Blockers",
        "standup[date]": "2020-01-01"
      })

      submit_form("#standup-form")

      assert visible?("Test Blockers")
      assert visible?("2020-01-01")
    end
  end

  describe "show" do
    setup do
      standup = insert(:standup)

      browser_sign_in()
      navigate_to(url())

      {:ok, standup: standup}
    end

    test "record details", %{standup: standup} do
      click_link(Date.to_string(standup.date))

      assert visible?(Date.to_string(standup.date))
      assert visible?(standup.blockers)
      assert visible?(standup.past)
    end
  end

  describe "edit / update" do
    setup do
      standup = insert(:standup)

      browser_sign_in()
      navigate_to(url())

      {:ok, standup: standup}
    end

    test "successfully updates record", %{standup: standup} do
      click_link(Date.to_string(standup.date))
      click_link("Edit")

      fill_inputs("#standup-form", %{
        "standup[blockers]": "Updated Blockers",
        "standup[date]": "2021-01-01"
      })

      submit_form("#standup-form")

      assert visible?("Updated Blockers")
      assert visible?("2021-01-01")
    end
  end

  describe "delete" do
    setup do
      standup = insert(:standup)

      browser_sign_in()
      navigate_to(url())

      {:ok, standup: standup}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{standup: standup} do
    #   click_link(standup.slug)
    #   click_button("Delete")
    #   accept_dialog()

    #   assert current_url() == url()
    #   assert not visible?(standup.slug)
    # end
  end
end
