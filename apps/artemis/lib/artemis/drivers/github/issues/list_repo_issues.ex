defmodule Artemis.Drivers.Github.ListRepoIssues do
  use Artemis.ContextCache

  alias Artemis.Drivers.Github
  alias Artemis.Drivers.Zenhub

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

  def call(organization, repository) do
    request = create_request_params(organization, repository)

    request
    |> get_all_pages()
    |> process_issues(request)
    |> add_zenhub_pipelines(request)
  end

  # Helpers

  defp create_request_params(organization, repository) do
    repository_path = "/repos/#{organization}/#{repository}"
    path = "/repos/#{organization}/#{repository}/issues"

    query_params = %{
      state: "open",
      per_page: @default_page_size
    }

    %{
      organization: organization,
      path: path,
      query_params: query_params,
      repository: repository,
      repository_path: repository_path
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

  defp add_zenhub_pipelines(data, request) do
    repository_id = get_repository_id(request)

    zenhub_pipeline_data =
      "/p1/repositories/#{repository_id}/board"
      |> Zenhub.Request.get()
      |> parse_response()
      |> parse_pipeline_data()

    merge_zenhub_pipeline_data(data, zenhub_pipeline_data)
  rescue
    _ -> data
  end

  defp parse_pipeline_data({:ok, response}) do
    pipelines =
      response.body
      |> Map.get("pipelines", [])
      |> Enum.with_index()

    Enum.reduce(pipelines, %{}, fn {pipeline, pipeline_index}, acc ->
      pipeline_id = Map.get(pipeline, "id")
      pipeline_name = Map.get(pipeline, "name")
      pipeline_issues = Map.get(pipeline, "issues")

      Enum.reduce(pipeline_issues, acc, fn issue, acc ->
        key = Map.get(issue, "issue_number")

        value = %{
          "zenhub_epic" => Map.get(issue, "is_epic"),
          "zenhub_estimate" => Artemis.Helpers.deep_get(issue, ["estimate", "value"]),
          "zenhub_pipeline" => pipeline_name,
          "zenhub_pipeline_id" => pipeline_id,
          "zenhub_pipeline_index" => pipeline_index,
          "zenhub_position" => Map.get(issue, "position")
        }

        Map.put(acc, key, value)
      end)
    end)
  end

  defp merge_zenhub_pipeline_data(data, zenhub_pipeline_data) do
    Enum.map(data, fn item ->
      key = Map.get(item, "number")
      additional_attributes = Map.get(zenhub_pipeline_data, key, %{})

      Map.merge(additional_attributes, item)
    end)
  end

  defp get_repository_id(request) do
    {:ok, response} =
      request
      |> Map.get(:repository_path)
      |> Github.Request.get()
      |> parse_response()

    Map.get(response.body, "id")
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
