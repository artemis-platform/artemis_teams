defmodule Artemis.ListGithubProject do
  use Artemis.Context

  @card_fields [
    "archived",
    "content_url",
    "created_at",
    "id",
    "node_id",
    "note",
    "updated_at"
    # "column_url",
    # "creator",
    # "project_url",
    # "url"
  ]

  @issue_fields [
    "assignee",
    "assignees",
    "created_at",
    "html_url",
    "id",
    "labels",
    "milestone",
    "number",
    "title",
    "updated_at"
  ]

  # TODO: recompile && Artemis.ListGithubProject.call(%{url: "https://github.ibm.com/tornado/vcloud-tracker/projects/17"}, nil)

  def call!(_params, _user) do
    # TODO
  end

  def call(params, _user) do
    params = Artemis.Helpers.keys_to_strings(params)

    project = get_project(params)
    issues = get_cached_repo_issues_by_issue_number(params)
    columns = get_project_columns(project)

    get_project_cards(columns, issues)
  end

  # Helpers - Project

  defp get_project(params) do
    options = parse_url_segments(params)
    organization = Keyword.fetch!(options, :organization)
    repository = Keyword.fetch!(options, :repository)
    project_number = Keyword.fetch!(options, :project_number)

    projects = Artemis.Drivers.Github.ListProjects.call(organization, repository)
    project = Enum.find(projects, &(Map.get(&1, "number") == project_number))
    error_message = "Error listing github project. Project '#{params["url"]}' not found"

    project || raise(Artemis.Context.Error, error_message)
  end

  defp parse_url_segments(params) do
    segments =
      params
      |> Map.fetch!("url")
      |> String.trim("/")
      |> String.split("/")
      |> Enum.take(-4)

    project_number =
      segments
      |> Enum.at(3)
      |> Artemis.Helpers.to_integer()

    [
      organization: Enum.at(segments, 0),
      repository: Enum.at(segments, 1),
      project_number: project_number
    ]
  end

  # Helpers - Repo Issues

  defp get_cached_repo_issues_by_issue_number(params) do
    options = parse_url_segments(params)
    organization = Keyword.fetch!(options, :organization)
    repository = Keyword.fetch!(options, :repository)

    organization
    |> Artemis.Drivers.Github.ListRepoIssues.call_with_cache(repository)
    |> Map.get(:data)
    |> Enum.reduce(%{}, fn issue, acc ->
      key = Map.get(issue, "number")

      Map.put(acc, key, issue)
    end)
  end

  # Helpers - Project Columns

  defp get_project_columns(project) do
    project
    |> Map.fetch!("id")
    |> Artemis.Drivers.Github.ListProjectColumns.call()
  end

  # Helpers - Project Cards

  defp get_project_cards(columns, issues) do
    Enum.reduce(columns, [], fn column, acc ->
      column_cards = get_column_cards(column, issues)

      column_cards ++ acc
    end)
  end

  defp get_column_cards(column, issues) do
    column
    |> Map.fetch!("id")
    |> Artemis.Drivers.Github.ListProjectCards.call()
    |> add_column_information(column)
    |> add_issue_information(issues)
  end

  defp add_column_information(cards, column) do
    column_id = Map.get(column, "id")
    column_name = Map.get(column, "name")

    Enum.map(cards, fn card ->
      card
      |> Map.take(@card_fields)
      |> Map.put("column_id", column_id)
      |> Map.put("column_name", column_name)
    end)
  end

  defp add_issue_information(cards, issues) do
    Enum.map(cards, fn card ->
      card_id = get_issue_id_from_card(card)
      issue = Map.get(issues, card_id, %{})
      issue_fields = Map.take(issue, @issue_fields)
      title = Map.get(issue, "title", card["note"])

      card
      |> Map.put("issue", issue_fields)
      |> Map.put("title", title)
    end)
  end

  defp get_issue_id_from_card(card) do
    is_github_issue_and_not_project_note? = Map.get(card, "note") == nil

    if is_github_issue_and_not_project_note? do
      card
      |> Map.get("content_url")
      |> String.split("/")
      |> List.last()
      |> Artemis.Helpers.to_integer()
    end
  end
end
