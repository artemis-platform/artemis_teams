defmodule ArtemisNotify.Worker.EventIntegrationNotifier do
  use ArtemisNotify.IntervalWorker,
    enabled: enabled?(),
    interval: :next_minute,
    delayed_start: :next_full_minute,
    name: :event_integration_notifier

  alias Artemis.GetSystemUser
  alias Artemis.ListEventIntegrations
  alias ArtemisNotify.CreateEventIntegrationNotification

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
    date = Timex.format!(Timex.now(), "{YYYY}-{0M}-{0D}")

    params = %{
      filters: %{
        active: true,
        schedule_not: nil
      }
    }

    params
    |> ListEventIntegrations.call(user)
    |> Enum.filter(&current?(&1, timestamp))
    |> Enum.map(fn event_integration ->
      CreateEventIntegrationNotification.call(event_integration.id, date, user)
    end)
  end

  # Helpers

  defp current?(event_integration, timestamp) do
    next_occurrence = Artemis.Helpers.Schedule.current(event_integration.schedule, timestamp)

    next_occurrence == timestamp
  end

  defp enabled?() do
    :artemis_notify
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:event_integration_notifier)
    |> Keyword.fetch!(:enabled)
    |> String.downcase()
    |> String.equivalent?("true")
  end
end
