defmodule Artemis.Helpers.Schedule do
  @moduledoc """
  Helper functions for Schedules

  Implemented using Cocktail: https://github.com/peek-travel/cocktail
  Documentation: https://hexdocs.pm/cocktail/
  """

  @doc """
  Encode Cocktail.Schedule struct as iCal string
  """
  def encode(%Cocktail.Schedule{} = value) do
    Cocktail.Schedule.to_i_calendar(value)
  end

  @doc """
  Decode iCal string as Cocktail.Schedule struct
  """
  def decode(value) when is_bitstring(value) do
    {:ok, result} = Cocktail.Schedule.from_i_calendar(value)

    result
  end

  def decode(%Cocktail.Schedule{} = value), do: value

  @doc """
  Return days of the week from recurrence rule
  """
  def days_of_the_week(schedule) do
    schedule
    |> get_schedule_validations()
    |> Artemis.Helpers.deep_get([:day, :days])
  end

  @doc """
  Return hours from recurrence rule
  """
  def hours(schedule) do
    schedule
    |> get_schedule_validations()
    |> Artemis.Helpers.deep_get([:hour_of_day, :hours], [])
  end

  @doc """
  Return hour from recurrence rule

  Note: assumes only one value for a given schedule
  """
  def hour(schedule) do
    schedule
    |> hours()
    |> List.first()
  end

  @doc """
  Return minutes from recurrence rule
  """
  def minutes(schedule) do
    schedule
    |> get_schedule_validations()
    |> Artemis.Helpers.deep_get([:minute_of_hour, :minutes], [])
  end

  @doc """
  Return minutes from recurrence rule

  Note: assumes only one value for a given schedule
  """
  def minute(schedule) do
    schedule
    |> minutes()
    |> List.first()
  end

  @doc """
  Return seconds from recurrence rule
  """
  def seconds(schedule) do
    schedule
    |> get_schedule_validations()
    |> Artemis.Helpers.deep_get([:second_of_minute, :seconds], [])
  end

  @doc """
  Return seconds from recurrence rule

  Note: assumes only one value for a given schedule
  """
  def second(schedule) do
    schedule
    |> seconds()
    |> List.first()
  end

  @doc """
  Humanize schedule value
  """
  def humanize(%Cocktail.Schedule{} = value) do
    value
    |> Cocktail.Schedule.to_string()
    |> String.replace("on  ", "on ")
    |> String.replace("on and", "on")
    |> String.replace(" on the 0th minute of the hour", "")
    |> String.replace(" on the 0th second of the minute", "")
  end

  def humanize(value) when is_bitstring(value) do
    value
    |> decode()
    |> humanize()
  end

  @doc """
  Returns the current scheduled date
  """
  def current(schedule, start_time \\ Timex.now())

  def current(%Cocktail.Schedule{} = schedule, start_time) do
    schedule
    |> Map.put(:start_time, start_time)
    |> Cocktail.Schedule.occurrences()
    |> Enum.take(1)
    |> hd()
  end

  def current(schedule, start_time) when is_bitstring(schedule) do
    current(decode(schedule), start_time)
  end

  # Helpers

  defp get_schedule_validations(schedule) do
    schedule
    |> Map.get(:recurrence_rules, [])
    |> List.first()
    |> Kernel.||(%{})
    |> Map.get(:validations, %{})
  end
end
