defmodule Artemis.Helpers.ScheduleTest do
  use Artemis.DataCase

  alias Artemis.Helpers.Schedule

  @timestamp ~U[2020-01-01 12:00:00Z]

  setup do
    options = [
      days: [0, 1, 2, 3, 4, 5, 6],
      hours: [12],
      minutes: [0],
      seconds: [0]
    ]

    schedule =
      @timestamp
      |> Cocktail.schedule()
      |> Cocktail.Schedule.add_recurrence_rule(:daily, options)

    {:ok, schedule: schedule}
  end

  describe "current" do
    test "returns current occurrence when passed identical timestamp", %{schedule: schedule} do
      exact_match = @timestamp
      one_second_after = Map.put(@timestamp, :second, 1)

      assert exact_match == Schedule.current(schedule, exact_match)
      assert one_second_after != Schedule.current(schedule, one_second_after)

      assert Schedule.current(schedule, exact_match) == ~U[2020-01-01 12:00:00Z]
      assert Schedule.current(schedule, one_second_after) == ~U[2020-01-02 12:00:00Z]
    end
  end

  describe "start date" do
    test "returns the start date of a Cocktail schedule" do
      schedule = Cocktail.schedule(@timestamp)

      result = Schedule.start_date(schedule)

      assert result == @timestamp
    end

    test "returns the start date of an encoded schedule" do
      schedule =
        @timestamp
        |> Cocktail.schedule()
        |> Schedule.encode()

      result = Schedule.start_date(schedule)

      assert result == @timestamp
    end

    test "returns the start date of custom string" do
      date = Timex.format!(@timestamp, "{YYYY}{0M}{0D}T{h24}{m}{s}")

      simple = "DTSTART=#{date}"
      complex = "DTSTART;TZID=Etc/UTC:#{date}"
      multiline = "DTEND=20301215T120000\nDTSTART;TZID=Etc/UTC:#{date}\nRRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR;BYHOUR=14;BYMINUTE=45"

      assert Schedule.start_date(simple) == @timestamp
      assert Schedule.start_date(complex) == @timestamp
      assert Schedule.start_date(multiline) == @timestamp
    end
  end

  describe "end date" do
    test "returns the end date of a Cocktail schedule" do
      duration_in_seconds = div(:timer.hours(72), 1_000)
      end_date = Timex.shift(@timestamp, seconds: duration_in_seconds)

      schedule = Cocktail.schedule(@timestamp, duration: duration_in_seconds)

      result = Schedule.end_date(schedule)

      assert result == end_date
    end

    test "returns the end date of an encoded schedule" do
      duration_in_seconds = div(:timer.hours(72), 1_000)
      end_date = Timex.shift(@timestamp, seconds: duration_in_seconds)

      schedule =
        @timestamp
        |> Cocktail.schedule(duration: duration_in_seconds)
        |> Schedule.encode()

      result = Schedule.end_date(schedule)

      assert result == end_date
    end

    test "returns the end date of custom string" do
      date = Timex.format!(@timestamp, "{YYYY}{0M}{0D}T{h24}{m}{s}")

      simple = "DTEND=#{date}"
      complex = "DTEND;TZID=Etc/UTC:#{date}"
      multiline = "DTSTART=20301215T120000\nDTEND;TZID=Etc/UTC:#{date}\nRRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR;BYHOUR=14;BYMINUTE=45"

      assert Schedule.end_date(simple) == @timestamp
      assert Schedule.end_date(complex) == @timestamp
      assert Schedule.end_date(multiline) == @timestamp
    end
  end
end
