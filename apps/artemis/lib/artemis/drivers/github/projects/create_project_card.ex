defmodule Artemis.Drivers.Github.CreateProjectCard do
  use Artemis.ContextCache

  alias Artemis.Drivers.Github

  def call(column_id, content_id) do
    path = "/projects/columns/#{column_id}/cards"
    payload = get_payload(content_id)

    path
    |> Github.Request.post(payload)
    |> parse_response()
  end

  defp get_payload(content_id) do
    Jason.encode!(%{
      content_id: Artemis.Helpers.to_integer(content_id),
      content_type: "Issue"
    })
  end

  defp parse_response({_, %HTTPoison.Response{} = response}) do
    status = parse_status_code(response)
    body = Map.get(response, :body, response)

    {status, body}
  end

  defp parse_response(error), do: error

  defp parse_status_code(%{status_code: status_code}) when status_code in 200..399, do: :ok
  defp parse_status_code(_error), do: :error
end
