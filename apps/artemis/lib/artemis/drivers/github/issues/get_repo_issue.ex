defmodule Artemis.Drivers.Github.GetRepoIssue do
  use Artemis.ContextCache

  alias Artemis.Drivers.Github
  alias Artemis.Drivers.Zenhub

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

  def call(organization, repository, id) do
    organization
    |> get_github_issue(repository, id)
    |> add_zenhub_epic(organization, repository, id)
  end

  # Helpers

  defp get_github_issue(organization, repository, id) do
    path = "/repos/#{organization}/#{repository}/issues/#{id}"

    path
    |> Github.Request.get()
    |> parse_response_body()
    |> Map.take(@fields)
    |> Map.put("organization", organization)
    |> Map.put("repository", repository)
  end

  defp parse_response_body({:ok, %HTTPoison.Response{body: body}}), do: body
  defp parse_response_body(error), do: error

  defp add_zenhub_epic(data, organization, repository, id) do
    repository_id = get_repository_id(organization, repository)
    path = "/p1/repositories/#{repository_id}/epics/#{id}"

    response =
      path
      |> Zenhub.Request.get()
      |> parse_response_body()

    zenhub_epic_estimate_total = Artemis.Helpers.deep_get(response, ["total_epic_estimates", "value"])
    zenhub_epic_issues = Map.get(response, "issues")
    zenhub_estimate = Artemis.Helpers.deep_get(response, ["estimate", "value"])
    zenhub_pipeline = get_zenhub_pipeline(response)

    zenhub_epic_issues_updated =
      Enum.map(zenhub_epic_issues, fn issue ->
        issue_number = Map.get(issue, "issue_number")
        zenhub_epic = Map.get(issue, "is_epic")
        zenhub_estimate = Artemis.Helpers.deep_get(issue, ["estimate", "value"])
        zenhub_pipeline = get_zenhub_pipeline(issue)

        organization
        |> get_github_issue(repository, issue_number)
        |> Map.put("zenhub_epic", zenhub_epic)
        |> Map.put("zenhub_estimate", zenhub_estimate)
        |> Map.put("zenhub_pipeline", zenhub_pipeline)
      end)

    data
    |> Map.put("zenhub_epic", true)
    |> Map.put("zenhub_epic_issues", zenhub_epic_issues_updated)
    |> Map.put("zenhub_epic_estimate_total", zenhub_epic_estimate_total)
    |> Map.put("zenhub_estimate", zenhub_estimate)
    |> Map.put("zenhub_pipeline", zenhub_pipeline)
  rescue
    _ -> data
  end

  defp get_zenhub_pipeline(data) do
    case Artemis.Helpers.deep_get(data, ["pipeline", "name"]) do
      "closed" -> "Closed"
      pipeline -> pipeline
    end
  end

  defp get_repository_id(organization, repository) do
    path = "/repos/#{organization}/#{repository}"

    path
    |> Github.Request.get()
    |> parse_response_body()
    |> Map.get("id")
  end
end
