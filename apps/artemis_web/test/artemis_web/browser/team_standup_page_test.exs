defmodule ArtemisWeb.TeamStandupPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser

  hound_session()

  defp get_url(team), do: team_standup_url(ArtemisWeb.Endpoint, :index, team)

  describe "authentication" do
    test "requires authentication" do
      standup = insert(:standup)

      navigate_to(get_url(standup.team))

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      standup = insert(:standup)

      browser_sign_in()
      navigate_to(get_url(standup.team))

      {:ok, standup: standup}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Team Standups")
    end
  end

  describe "show" do
    setup do
      standup = insert(:standup)

      browser_sign_in()
      navigate_to(get_url(standup.team))

      {:ok, standup: standup}
    end

    test "record details", %{standup: standup} do
      click_link(Date.to_string(standup.date))

      assert visible?(String.slice(standup.blockers, 0..10))
      assert visible?(standup.user.name)
    end
  end
end
