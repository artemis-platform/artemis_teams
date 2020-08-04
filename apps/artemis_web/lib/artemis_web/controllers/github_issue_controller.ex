defmodule ArtemisWeb.GithubIssueController do
  use ArtemisWeb, :controller

  alias Artemis.ListGithubIssues

  @default_columns [
    "number",
    "assignee",
    "zenhub_pipeline",
    "title",
    "labels",
    "comments",
    "created_at"
  ]

  def index(conn, params) do
    authorize(conn, "github-issues:list", fn ->
      user = current_user(conn)
      github_issues_all = ListGithubIssues.call(user)
      github_issues_filtered = ListGithubIssues.call(params, user)

      assigns = [
        default_columns: @default_columns,
        github_issues_all: github_issues_all,
        github_issues_filtered: github_issues_filtered
      ]

      render_format(conn, "index", assigns)
    end)
  end
end
