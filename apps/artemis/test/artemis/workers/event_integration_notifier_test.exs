defmodule Artemis.Worker.EventIntegrationNotifierTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.EventIntegration
  alias Artemis.Repo
  alias Artemis.Worker.EventIntegrationNotifier

  @config %{}
  @data %{}

  setup do
    Repo.delete_all(EventIntegration)

    {:ok, []}
  end

  describe "call" do
    test "is asynchronous and returns a task" do
      {:ok, _pid} = EventIntegrationNotifier.call(@data, @config)
    end
  end

  describe "send_notifications" do
    test "notifies if there are matches" do
      hour = 12
      timestamp = get_timestamp(hour: hour)
      schedule = get_schedule(hour: hour)

      insert_list(3, :event_integration, schedule: schedule)

      result = EventIntegrationNotifier.send_notifications(timestamp)

      assert length(result) == 3
    end

    test "does not notify if there are no matches" do
      hour = 12
      timestamp = get_timestamp(hour: hour)
      schedule = get_schedule(hour: hour - 1)

      insert_list(3, :event_integration, schedule: schedule)

      result = EventIntegrationNotifier.send_notifications(timestamp)

      assert length(result) == 0
    end
  end

  # Helpers

  defp get_timestamp(options) do
    default_options = [
      year: "2020",
      month: "01",
      day: "01",
      hour: "12",
      minute: "00",
      second: "00",
      timezone: "Z"
    ]

    data =
      default_options
      |> Keyword.merge(options)
      |> Enum.into(%{})

    timestring = "#{data.year}-#{data.month}-#{data.day} #{data.hour}:#{data.minute}:#{data.minute}#{data.timezone}"

    Timex.parse!(timestring, "{ISO:Extended:Z}")
  end

  defp get_schedule(options) do
    default_options = [
      year: "2020",
      month: "01",
      day: "01",
      hour: "12",
      minute: "0",
      second: "0"
    ]

    data =
      default_options
      |> Keyword.merge(options)
      |> Enum.into(%{})

    date = "DTSTART:#{data.year}#{data.month}#{data.day}T000000"
    rule = "RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR;BYHOUR=#{data.hour};BYMINUTE=#{data.minute};BYSECOND=#{data.second}"

    "#{date}\n#{rule}"
  end
end
