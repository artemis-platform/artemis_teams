defmodule Artemis.Drivers.Github.MoveProjectCard do
  use Artemis.ContextCache

  alias Artemis.Drivers.Github

  def call(column_id, content_id, options \\ []) do
    path = "/projects/columns/cards/#{content_id}/moves"
    payload = get_payload(column_id, options)

    path
    |> Github.Request.post(payload)
    |> parse_response()
  end

  defp get_payload(column_id, options) do
    position = Keyword.get(options, :position, "top")

    Jason.encode!(%{
      column_id: Artemis.Helpers.to_integer(column_id),
      position: position
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
