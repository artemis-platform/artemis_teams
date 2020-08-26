defmodule ArtemisWeb.GithubIssueController do
  use ArtemisWeb, :controller

  alias Artemis.ListGithubIssues

  @default_columns [
    "number",
    "milestone",
    "zenhub_pipeline",
    "zenhub_estimate",
    "title",
    "labels",
    "assignee",
    "comments",
    "created_at",
    "actions"
  ]

  @default_page_size 5

  def index(conn, params) do
    authorize(conn, "github-issues:list", fn ->
      user = current_user(conn)
      github_repositories = get_github_repositories()
      github_issues_all = ListGithubIssues.call(user)
      github_issues_filtered = ListGithubIssues.call(params, user)
      zenhub_epics? = Enum.any?(github_issues_all, &Map.get(&1, "zenhub_epic"))

      assigns = [
        default_columns: @default_columns,
        default_page_size: @default_page_size,
        github_issues_all: github_issues_all,
        github_issues_filtered: github_issues_filtered,
        github_repositories: github_repositories,
        zenhub_epics?: zenhub_epics?
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def show(conn, %{"id" => id, "organization" => organization, "repository" => repository}) do
    authorize(conn, "github-issues:show", fn ->
      user = current_user(conn)
      github_issue = Artemis.GetGithubIssue.call(organization, repository, id, user)
      github_issues = ListGithubIssues.call(user)

      assigns = [
        default_columns: @default_columns,
        github_issue: github_issue,
        github_issues: github_issues
      ]

      render(conn, "show.html", assigns)
    end)
  end

  # Helpers

  defp get_github_repositories() do
    :artemis
    |> Application.fetch_env!(:github)
    |> Keyword.fetch!(:repositories)
  end
end
