defmodule ArtemisWeb.RecognitionPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser
  @url recognition_url(ArtemisWeb.Endpoint, :index)

  hound_session()

  describe "authentication" do
    test "requires authentication" do
      navigate_to(@url)

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      recognition = insert(:recognition)

      browser_sign_in()
      navigate_to(@url)

      {:ok, recognition: recognition}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Recognitions")
    end

    test "search", %{recognition: recognition} do
      fill_inputs(".search-resource", %{
        query: recognition.name
      })

      submit_search(".search-resource")

      assert visible?(recognition.name)
    end
  end

  describe "new / create" do
    setup do
      browser_sign_in()
      navigate_to(@url)

      {:ok, []}
    end

    test "submitting an empty form shows an error" do
      click_link("New")
      submit_form("#recognition-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record" do
      click_link("New")

      fill_inputs("#recognition-form", %{
        "recognition[name]": "Test Name",
        "recognition[slug]": "test-slug"
      })

      submit_form("#recognition-form")

      assert visible?("Test Name")
      assert visible?("test-slug")
    end
  end

  describe "show" do
    setup do
      recognition =
        :recognition
        |> insert()
        |> with_permissions()

      browser_sign_in()
      navigate_to(@url)

      {:ok, recognition: recognition}
    end

    test "record details and associations", %{recognition: recognition} do
      click_link(recognition.name)

      assert visible?(recognition.name)
      assert visible?(recognition.slug)

      assert visible?("Permissions")
    end
  end

  describe "edit / update" do
    setup do
      recognition = insert(:recognition)

      browser_sign_in()
      navigate_to(@url)

      {:ok, recognition: recognition}
    end

    test "successfully updates record", %{recognition: recognition} do
      click_link(recognition.name)
      click_link("Edit")

      fill_inputs("#recognition-form", %{
        "recognition[name]": "Updated Name",
        "recognition[slug]": "updated-slug"
      })

      submit_form("#recognition-form")

      assert visible?("Updated Name")
      assert visible?("updated-slug")
    end
  end

  describe "delete" do
    setup do
      recognition = insert(:recognition)

      browser_sign_in()
      navigate_to(@url)

      {:ok, recognition: recognition}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{recognition: recognition} do
    #   click_link(recognition.name)
    #   click_button("Delete")
    #   accept_dialog()

    #   assert current_url() == @url
    #   assert not visible?(recognition.name)
    # end
  end
end
