defmodule Artemis.Worker.EventIntegrationNotifier do
  use Artemis.IntervalWorker,
    enabled: enabled?(),
    interval: :next_minute,
    delayed_start: :next_full_minute,
    name: :event_integration_notifier

  alias Artemis.GetSystemUser
  alias Artemis.ListEventIntegrations

  # Callbacks

  @impl true
  def call(_data, _config) do
    timestamp = Artemis.Helpers.Time.beginning_of_minute(Timex.now())

    Task.start_link(fn ->
      send_notifications(timestamp)
    end)
  end

  def send_notifications(timestamp) do
    user = GetSystemUser.call!()

    params = %{
      filters: %{
        active: true,
        schedule_not: nil
      }
    }

    params
    |> ListEventIntegrations.call(user)
    |> Enum.filter(&current?(&1, timestamp))
    |> Enum.map(fn _ ->
      true
    end)
  end

  # Helpers

  defp current?(event_integration, timestamp) do
    next_occurrence = Artemis.Helpers.Schedule.current(event_integration.schedule, timestamp)

    next_occurrence == timestamp
  end

  defp enabled?() do
    :artemis
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:event_integration_notifier)
    |> Keyword.fetch!(:enabled)
    |> String.downcase()
    |> String.equivalent?("true")
  end
end
