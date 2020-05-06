defmodule ArtemisWeb.ProjectPageTest do
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
      project = insert(:project)
      url = get_url(project.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, project: project}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Event Questions")
    end

    test "search", %{project: project} do
      fill_inputs(".search-resource", %{
        query: project.title
      })

      submit_search(".search-resource")

      assert visible?(project.title)
    end
  end

  describe "new / create" do
    setup do
      project = insert(:project)
      url = get_url(project.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, project: project}
    end

    test "submitting an empty form shows an error" do
      click_link("New")
      submit_form("#project-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record", %{project: project} do
      click_link("New")

      fill_inputs("#project-form", %{
        "project[title]": "Test Title"
      })

      fill_select("#project-form select[name=project[project_id]]", project.id)

      submit_form("#project-form")

      assert visible?("Test Title")
    end
  end

  describe "show" do
    setup do
      project = insert(:project)
      url = get_url(project.event_template)

      Artemis.ListProjects.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, project: project}
    end

    test "record details", %{project: project} do
      click_link(project.title)

      assert visible?(project.title)
    end
  end

  describe "edit / update" do
    setup do
      project = insert(:project)
      url = get_url(project.event_template)

      Artemis.ListProjects.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, project: project}
    end

    test "successfully updates record", %{project: project} do
      click_link(project.title)
      click_link("Edit")

      fill_inputs("#project-form", %{
        "project[title]": "Updated Title"
      })

      submit_form("#project-form")

      assert visible?("Updated Title")
    end
  end

  describe "delete" do
    setup do
      project = insert(:project)
      url = get_url(project.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, project: project}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{project: project} do
    #   click_link(project.title)
    #   click_button("Delete")
    #   accept_dialog()
    #
    #   assert current_url() == get_url(project.event_template)
    #   assert not visible?(project.title)
    # end
  end

  # Helpers

  defp get_url(event_template) do
    _project = insert(:project, event_template: event_template)

    project_url(ArtemisWeb.Endpoint, :index, event_template)
  end
end
