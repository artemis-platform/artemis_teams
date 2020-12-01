defmodule ArtemisNotify.ViewHelper.Url do
  @doc """
  Prints a full Artemis Web URL for a given path
  """
  def artemis_web_url(raw_path) when is_bitstring(raw_path) do
    domain = Application.fetch_env!(:artemis_notify, :artemis_web_url)
    path = String.trim_leading(raw_path, "/")

    "https://" <> domain <> "/" <> path
  end
end
