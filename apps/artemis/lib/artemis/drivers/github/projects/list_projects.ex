defmodule Artemis.Drivers.Github.ListProjects do
  use Artemis.ContextCache

  alias Artemis.Drivers.Github

  @default_page_size 100

  def call(organization, repository) do
    organization
    |> create_request_params(repository)
    |> get_all_pages()
  end

  # Helpers

  defp create_request_params(organization, repository) do
    path = "/repos/#{organization}/#{repository}/projects"

    query_params = %{
      per_page: @default_page_size,
      state: "open"
    }

    %{
      organization: organization,
      path: path,
      query_params: query_params,
      repository: repository
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
