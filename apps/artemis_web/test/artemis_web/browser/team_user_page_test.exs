defmodule ArtemisWeb.TeamUserPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser

  hound_session()

  defp get_url(team), do: team_user_url(ArtemisWeb.Endpoint, :index, team)

  describe "authentication" do
    test "requires authentication" do
      team_user = insert(:team_user)

      navigate_to(get_url(team_user.team))

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      team_user = insert(:team_user)

      browser_sign_in()
      navigate_to(get_url(team_user.team))

      {:ok, team_user: team_user}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Team Users")
    end
  end

  describe "new / create" do
    setup do
      team_user = insert(:team_user)

      browser_sign_in()
      navigate_to(get_url(team_user.team))

      {:ok, []}
    end

    test "submitting an empty form succeeds with the defaults" do
      click_link("New")

      submit_form("#team-user-form")

      assert visible?("Member")
    end

    test "successfully creates a new record" do
      click_link("New")

      fill_enhanced_select("#team-user-form .field-type", "Admin")

      submit_form("#team-user-form")

      assert visible?("Admin")
    end
  end

  describe "show" do
    setup do
      team_user = insert(:team_user)

      browser_sign_in()
      navigate_to(get_url(team_user.team))

      {:ok, team_user: team_user}
    end

    test "record details", %{team_user: team_user} do
      click_link(team_user.user.name)

      assert visible?(team_user.team.name)
      assert visible?(team_user.type)
      assert visible?(team_user.user.name)
    end
  end

  describe "edit / update" do
    setup do
      team_user = insert(:team_user)

      browser_sign_in()
      navigate_to(get_url(team_user.team))

      {:ok, team_user: team_user}
    end

    test "successfully updates record", %{team_user: team_user} do
      click_link(team_user.user.name)
      click_link("Edit")

      fill_enhanced_select("#team-user-form .field-type", "Member")

      submit_form("#team-user-form")

      assert visible?("Member")
    end
  end

  describe "delete" do
    setup do
      team_user = insert(:team_user)

      browser_sign_in()
      navigate_to(get_url(team_user.team))

      {:ok, team_user: team_user}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{team_user: team_user} do
    #   click_link(team_user.slug)
    #   click_button("Remove")
    #   accept_dialog()

    #   assert current_url() == get_url(team_user.team)
    #   assert not visible?(team_user.slug)
    # end
  end
end
