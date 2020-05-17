defmodule Artemis.ListEventReportsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.EventAnswer
  alias Artemis.ListEventReports

  setup do
    Repo.delete_all(EventAnswer)

    {:ok, []}
  end

  describe "call - report - event_instance_engagement_by_date" do
    test "returns an empty list when no data is present" do
      result = get_report(:event_instance_engagement_by_date)

      assert result == []
    end

    test "returns an list when data is present" do
      date = Date.utc_today()
      user1 = insert(:user)
      user2 = insert(:user)

      event_template = insert(:event_template)
      event_question = insert(:event_question, event_template: event_template)

      event_answers = insert_list(1, :event_answer, date: date, event_question: event_question, user: user1)
      event_answers = insert_list(2, :event_answer, date: date, event_question: event_question, user: user2)

      result = get_report(:event_instance_engagement_by_date)

      # TODO: result should only be count of unique user ids

      assert result == []
    end
  end

  # Helpers

  defp get_report(report, params \\ %{}, user \\ nil) do
    user = user || Mock.system_user()

    report
    |> ListEventReports.call(params, user)
    |> Map.get(report)
  end
end
