defmodule ArtemisWeb.EventQuestionPageTest do
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
      event_question = insert(:event_question)
      url = get_url(event_question.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_question: event_question}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Event Questions")
    end

    test "search", %{event_question: event_question} do
      fill_inputs(".search-resource", %{
        query: event_question.title
      })

      submit_search(".search-resource")

      assert visible?(event_question.title)
    end
  end

  describe "new / create" do
    setup do
      event_question = insert(:event_question)
      url = get_url(event_question.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_question: event_question}
    end

    test "submitting an empty form shows an error" do
      click_link("New")
      submit_form("#event-question-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record", %{event_question: event_question} do
      click_link("New")

      fill_inputs("#event-question-form", %{
        "event_question[title]": "Test Title"
      })

      fill_select("#event-question-form select[name=event_question[event_question_id]]", event_question.id)

      submit_form("#event-question-form")

      assert visible?("Test Title")
    end
  end

  describe "show" do
    setup do
      event_question = insert(:event_question)
      url = get_url(event_question.event_template)

      Artemis.ListEventQuestions.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, event_question: event_question}
    end

    test "record details", %{event_question: event_question} do
      click_link(event_question.title)

      assert visible?(event_question.title)
    end
  end

  describe "edit / update" do
    setup do
      event_question = insert(:event_question)
      url = get_url(event_question.event_template)

      Artemis.ListEventQuestions.reset_cache()

      browser_sign_in()
      navigate_to(url)

      {:ok, event_question: event_question}
    end

    test "successfully updates record", %{event_question: event_question} do
      click_link(event_question.title)
      click_link("Edit")

      fill_inputs("#event-question-form", %{
        "event_question[title]": "Updated Title"
      })

      submit_form("#event-question-form")

      assert visible?("Updated Title")
    end
  end

  describe "delete" do
    setup do
      event_question = insert(:event_question)
      url = get_url(event_question.event_template)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_question: event_question}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{event_question: event_question} do
    #   click_link(event_question.title)
    #   click_button("Delete")
    #   accept_dialog()
    #
    #   assert current_url() == get_url(event_question.event_template)
    #   assert not visible?(event_question.title)
    # end
  end

  # Helpers

  defp get_url(event_template) do
    _event_question = insert(:event_question, event_template: event_template)

    event_question_url(ArtemisWeb.Endpoint, :index, event_template)
  end
end
