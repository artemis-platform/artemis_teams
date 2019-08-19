defmodule ArtemisWeb.ViewHelper.Print do
  use Phoenix.HTML

  @doc """
  Print date in human readable format
  """
  def render_date(value, format \\ "{Mfull} {D}, {YYYY}")

  def render_date(value, format) when is_number(value) do
    value
    |> Timex.from_unix()
    |> render_date(format)
  end

  def render_date(value, format) do
    value
    |> Timex.Timezone.convert("America/New_York")
    |> Timex.format!(format)
  end

  @doc """
  Print date in human readable format
  """
  def render_date_time(value, format \\ "{Mfull} {D}, {YYYY} at {h12}:{m}{am} {Zabbr}")

  def render_date_time(value, format) when is_number(value) do
    value
    |> Timex.from_unix()
    |> render_date_time(format)
  end

  def render_date_time(value, format) do
    value
    |> Timex.Timezone.convert("America/New_York")
    |> Timex.format!(format)
  end

  @doc """
  Print date in human readable format with seconds
  """
  def render_date_time_with_seconds(value, format \\ "{Mfull} {D}, {YYYY} at {h12}:{m}:{s}{am} {Zabbr}")

  def render_date_time_with_seconds(value, format) when is_number(value) do
    value
    |> Timex.from_unix()
    |> render_date_time_with_seconds(format)
  end

  def render_date_time_with_seconds(value, format) do
    value
    |> Timex.Timezone.convert("America/New_York")
    |> Timex.format!(format)
  end

  @doc """
  Print time in human readable format with seconds
  """
  def render_time(value, format \\ "{h12}:{m}:{s}{am} {Zabbr}")

  def render_time(nil, _format), do: nil

  def render_time(value, format) when is_number(value) do
    value
    |> Timex.from_unix()
    |> render_time(format)
  end

  def render_time(value, format) do
    value
    |> Timex.Timezone.convert("America/New_York")
    |> Timex.format!(format)
  end

  @doc """
  Print date in relative time, e.g. "3 minutes ago"
  """
  def render_relative_time(value, format \\ "{relative}")

  def render_relative_time(value, format) when is_number(value) do
    value
    |> Timex.from_unix()
    |> render_relative_time(format)
  end

  def render_relative_time(value, format) do
    Timex.format!(value, format, :relative)
  end

  @doc """
  Encodes JSON compatable data into a pretty printed string
  """
  def pretty_print_json_into_textarea(form, key) do
    form
    |> input_value(key)
    |> pretty_print_value()
  end

  defp pretty_print_value(value) when is_map(value), do: Jason.encode!(value, pretty: true)
  defp pretty_print_value(value), do: value
end