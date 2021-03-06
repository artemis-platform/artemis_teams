defmodule ArtemisNotify.EventInstanceView do
  use ArtemisNotify, :view

  @doc """
  Format value for slack
  """
  def render_value_slack(%{type: "number"} = record) do
    case record.value_percent do
      nil -> "#{record.value_number || record.value}"
      _ -> "#{record.value_number} _(#{render_value_percent(record.value_percent)}%)_"
    end
  end

  def render_value_slack(record) do
    convert_html_to_slack_markdown!(record.value_html)
  rescue
    _ -> record.value
  end

  @doc """
  Render value as a percent
  """
  def render_value_percent(percent) when not is_nil(percent) do
    percent
    |> Decimal.to_float()
    |> Kernel.*(100)
    |> Float.round(1)
  end

  @doc """
  Render event instance date
  """
  def render_event_instance_date(date) when is_bitstring(date) do
    date
    |> Date.from_iso8601!()
    |> render_event_instance_date()
  end

  def render_event_instance_date(date) do
    Timex.format!(date, "{WDfull}, {Mfull} {D}, {YYYY}")
  end
end
