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

  describe "call - report - event_questions_percent_by_date" do
    test "returns an empty list when no data is present" do
      result = get_report(:event_questions_percent_by_date)

      assert result == []
    end

    test "returns an list when data is present" do
      user1 = insert(:user)
      user2 = insert(:user)

      event_template = insert(:event_template)
      event_question = insert(:event_question, event_template: event_template, type: "number")

      project1 = insert(:project, team: event_template.team)
      project2 = insert(:project, team: event_template.team)

      date_current = Date.utc_today()
      date_past = Timex.shift(Date.utc_today(), weeks: -1)

      insert_list(1, :event_answer,
        value: "5",
        value_number: 5,
        date: date_past,
        event_question: event_question,
        user: user1,
        project: project1
      )

      insert_list(1, :event_answer,
        value: "10",
        value_number: 10,
        date: date_past,
        event_question: event_question,
        user: user1,
        project: project2
      )

      insert_list(2, :event_answer,
        value: "5",
        value_number: 5,
        date: date_past,
        event_question: event_question,
        user: user2,
        project: project1
      )

      insert_list(2, :event_answer,
        value: "10",
        value_number: 10,
        date: date_past,
        event_question: event_question,
        user: user2,
        project: project2
      )

      insert_list(2, :event_answer,
        value: "5",
        value_number: 5,
        date: date_current,
        event_question: event_question,
        user: user1,
        project: project1
      )

      insert_list(2, :event_answer,
        value: "10",
        value_number: 10,
        date: date_current,
        event_question: event_question,
        user: user1,
        project: project2
      )

      result = get_report(:event_questions_percent_by_date)

      assert length(result) == 4
      assert Enum.at(result, 0) == [event_question.id, date_past, project1.id, Decimal.new(15)]
      assert Enum.at(result, 1) == [event_question.id, date_past, project2.id, Decimal.new(30)]
      assert Enum.at(result, 2) == [event_question.id, date_current, project1.id, Decimal.new(10)]
      assert Enum.at(result, 3) == [event_question.id, date_current, project2.id, Decimal.new(20)]
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
