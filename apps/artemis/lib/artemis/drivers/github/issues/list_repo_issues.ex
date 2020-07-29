defmodule Artemis.Drivers.Github.ListRepoIssues do
  use Artemis.ContextCache

  alias Artemis.Drivers.Github

  @default_page_size 100

  @fields [
    "assignee",
    "assignees",
    "closed_at",
    "comments",
    "comments_url",
    "created_at",
    "html_url",
    "id",
    "labels",
    "labels_url",
    "milestone",
    "number",
    "state",
    "title",
    "updated_at",
    "url",
    "user"
  ]

  def call(repositories) do
    Enum.reduce(repositories, [], fn repository, acc ->
      get_issues_for_repository(repository) ++ acc
    end)
  end

  # Helpers

  defp get_issues_for_repository(repository) do
    headers = [
      "Authorization": "Basic #{get_github_token()}"
    ]

    domain = get_github_url()
    organization = Keyword.get(repository, :organization)
    repository = Keyword.get(repository, :repository)
    url = "#{domain}/repos/#{organization}/#{repository}/issues"

    query_params = %{
      state: "open",
      per_page: @default_page_size
    }

    request = %{
      headers: headers,
      query_params: query_params,
      organization: organization,
      repository: repository,
      url: url
    }

    request
    |> get_pages()
    |> process_issues(request)
  end

  defp get_pages(request, acc \\ [], page \\ 1) do
    encoded_query_params =
      request.query_params
      |> Map.put(:page, page)
      |> Plug.Conn.Query.encode()

    {:ok, response} =
      "#{request.url}?#{encoded_query_params}"
      |> Github.Request.get(request.headers)
      |> parse_response()

    acc = response.body ++ acc

    case length(response.body) >= @default_page_size do
      true -> get_pages(request, acc, page + 1)
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

  defp get_github_token() do
    :artemis
    |> Application.fetch_env!(:github)
    |> Keyword.fetch!(:token)
  end

  defp get_github_url() do
    :artemis
    |> Application.fetch_env!(:github)
    |> Keyword.fetch!(:url)
  end

  defp process_issues(data, request) do
    data
    |> Enum.reject(&Map.get(&1, "pull_request"))
    |> Enum.map(fn item ->
      item
      |> Map.take(@fields)
      |> Map.put("organization", request.organization)
      |> Map.put("repository", request.repository)
    end)
  end
end
