defmodule Artemis.Drivers.Github.ListProjectCards do
  use Artemis.ContextCache

  alias Artemis.Drivers.Github

  @moduledoc """
  List Github Project Cards

  NOTE: the `updated_at` timestamp is the last time it was moved into the column
  """

  @default_page_size 100

  def call(column_id) do
    column_id
    |> create_request_params()
    |> get_all_pages()
  end

  # Helpers

  defp create_request_params(column_id) do
    path = "/projects/columns/#{column_id}/cards"

    query_params = %{
      per_page: @default_page_size
    }

    %{
      path: path,
      query_params: query_params
    }
  end

  defp get_all_pages(request_params, acc \\ [], current_page \\ 1) do
    encoded_query_params =
      request_params
      |> Map.get(:query_params)
      |> Map.put(:page, current_page)
      |> Plug.Conn.Query.encode()

    {:ok, response} =
      "#{request_params.path}?#{encoded_query_params}"
      |> Github.Request.get()
      |> parse_response()

    acc = response.body ++ acc

    case length(response.body) >= @default_page_size do
      true -> get_all_pages(request_params, acc, current_page + 1)
      false -> acc
    end
  end

  defp parse_response({_, %HTTPoison.Response{} = response}) do
    status = parse_status_code(response)

    {status, response}
  end

  defp parse_response(error), do: error

  defp parse_status_code(%{status_code: status_code}) when status_code in 200..399, do: :ok
  defp parse_status_code(_error), do: :error
end
