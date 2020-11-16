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
  Humanize schedule value
  """
  def humanize(%Cocktail.Schedule{} = value) do
    value
    |> Cocktail.Schedule.to_string()
    |> String.replace("on  ", "on ")
    |> String.replace("on and", "on")
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
end
