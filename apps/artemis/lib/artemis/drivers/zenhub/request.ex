defmodule Artemis.Drivers.Zenhub.Request do
  use HTTPoison.Base

  def process_request_headers(headers) do
    [
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-Authentication-Token": get_zenhub_token()
    ] ++ headers
  end

  def process_request_url(path), do: "#{get_zenhub_url()}#{path}"

  def process_response_body(body) do
    Jason.decode!(body)
  rescue
    _ -> body
  end

  # Helpers

  defp get_zenhub_token() do
    :artemis
    |> Application.fetch_env!(:zenhub)
    |> Keyword.fetch!(:token)
  end

  defp get_zenhub_url() do
    :artemis
    |> Application.fetch_env!(:zenhub)
    |> Keyword.fetch!(:url)
  end
end
