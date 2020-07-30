defmodule ArtemisWeb.GithubIssueController do
  use ArtemisWeb, :controller

  alias Artemis.ListGithubIssues

  @default_columns [
    "number",
    "assignee",
    "zenhub_pipeline",
    "title",
    "labels"
  ]

  def index(conn, params) do
    authorize(conn, "github-issues:list", fn ->
      user = current_user(conn)
      github_issues = ListGithubIssues.call(params, user)
      # filter_paths = ListGithubIssues.call(%{distinct: :path}, user)

      assigns = [
        default_columns: @default_columns,
        github_issues: github_issues
      ]

      render_format(conn, "index", assigns)
    end)
  end
end
