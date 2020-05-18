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
      user1 = insert(:user)
      user2 = insert(:user)

      event_template = insert(:event_template)
      event_question = insert(:event_question, event_template: event_template)

      date_current = Date.utc_today()
      date_past = Timex.shift(Date.utc_today(), weeks: -1)

      insert_list(1, :event_answer, date: date_past, event_question: event_question, user: user1)
      insert_list(2, :event_answer, date: date_past, event_question: event_question, user: user2)
      insert_list(3, :event_answer, date: date_current, event_question: event_question, user: user1)

      result = get_report(:event_instance_engagement_by_date)

      assert length(result) == 2
      assert Enum.at(result, 0) == [date_past, 2]
      assert Enum.at(result, 1) == [date_current, 1]
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
