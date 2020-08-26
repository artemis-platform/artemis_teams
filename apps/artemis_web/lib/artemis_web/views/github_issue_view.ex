defmodule ArtemisWeb.GithubIssueView do
  use ArtemisWeb, :view

  def data_table_available_columns() do
    [
      {"Assignee", "assignee"},
      {"Comments", "comments"},
      {"Created At", "created_at"},
      {"Epic", "zenhub_epic"},
      {"Estimate", "zenhub_estimate"},
      {"Labels", "labels"},
      {"Milestone", "milestone"},
      {"Number", "number"},
      {"Title", "title"},
      {"Pipeline", "zenhub_pipeline"}
    ]
  end

  def data_table_allowed_columns() do
    %{
      "assignee" => [
        label: fn _conn -> "Assignees" end,
        value: fn _conn, row ->
          row
          |> Map.get("assignees")
          |> Enum.map(&Map.get(&1, "login"))
          |> List.flatten()
          |> Enum.join(", ")
        end,
        value_html: fn _conn, row ->
          case length(row["assignees"]) > 0 do
            true ->
              Enum.map(row["assignees"], fn assignee ->
                content_tag(:div, assignee["login"])
              end)

            false ->
              content_tag(:div, "-")
          end
        end
      ],
      "comments" => [
        label: fn _conn -> "Comments" end,
        value: fn _conn, row -> row["comments"] end,
        value_html: fn _conn, row ->
          url = String.replace(row["url"], "/api/v3/repos", "")

          link(row["comments"], to: url, target: "_blank")
        end
      ],
      "created_at" => [
        label: fn _conn -> "Created At" end,
        value: fn _conn, row -> row["created_at"] end,
        value_html: fn _conn, row ->
          row
          |> Map.get("created_at")
          |> DateTime.from_iso8601()
          |> elem(1)
          |> render_date_time()
        end
      ],
      "labels" => [
        label: fn _conn -> "Labels" end,
        value: fn _conn, row ->
          row
          |> Map.get("labels")
          |> Enum.sort_by(&String.downcase(&1["name"]))
          |> Enum.map(&Map.get(&1, "name"))
          |> Enum.join(", ")
        end,
        value_html: fn _conn, row -> render_labels(row) end
      ],
      "milestone" => [
        label: fn _conn -> "Milestone" end,
        value: fn _conn, row -> Artemis.Helpers.deep_get(row, ["milestone", "title"]) end
      ],
      "number" => [
        label: fn _conn -> "Number" end,
        value: fn _conn, row -> row["number"] end,
        value_html: fn _conn, row ->
          url = String.replace(row["url"], "/api/v3/repos", "")

          link(row["number"], to: url, target: "_blank")
        end
      ],
      "title" => [
        label: fn _conn -> "Title" end,
        value: fn _conn, row -> row["title"] end,
        value_html: fn _conn, row ->
          url = String.replace(row["url"], "/api/v3/repos", "")

          link(row["title"], to: url, target: "_blank")
        end
      ],
      "zenhub_epic" => [
        label: fn _conn -> "Epic" end,
        value: fn _conn, row -> row["zenhub_epic"] end,
        value_html: fn _conn, row ->
          case row["zenhub_epic"] do
            true -> "Epic"
            _ -> nil
          end
        end
      ],
      "zenhub_estimate" => [
        label: fn _conn -> "Estimate" end,
        value: fn _conn, row -> row["zenhub_estimate"] end
      ],
      "zenhub_pipeline" => [
        label: fn _conn -> "Pipeline" end,
        value: fn _conn, row -> row["zenhub_pipeline"] end
      ]
    }
  end

  @doc """
  Render labels
  """
  def render_labels(github_issue) do
    github_issue
    |> Map.get("labels")
    |> Enum.sort_by(&String.downcase(&1["name"]))
    |> Enum.map(fn label ->
      href = String.replace(label["url"], "/api/v3/repos", "")
      label_color = label["color"]
      text_color = get_text_color(label_color)

      content_tag(:div) do
        content_tag(:a, label["name"],
          href: href,
          class: "github-issue-label",
          style: "background: ##{label_color}; color: #{text_color}",
          target: "_blank"
        )
      end
    end)
  end

  @doc """
  Return true if there's more than the current page size
  """
  def more?(data, page_size \\ 10), do: length(data) > page_size

  @doc """
  Return true if `show_all` query param is set for specified key
  """
  def show_all?(conn, key) do
    fields = Map.get(conn.query_params, "show_all", [])

    Enum.member?(fields, key)
  end

  @doc """
  Render a `Show All` or `Hide All` button
  """
  def show_all_button(conn, data, key, page_size \\ 10) do
    current = Map.get(conn.query_params, "show_all", [])

    content_tag(:div, class: "show-all-button") do
      case show_all?(conn, key) && more?(data, page_size) do
        true -> query_param_button(conn, "Hide All", show_all: List.delete(current, key))
        false -> query_param_button(conn, "Show All", show_all: [key] ++ current)
      end
    end
  end

  @doc """
  Total estimate and issues for a list of github issues
  """
  def total_estimates_and_issues_by(data, field) do
    Enum.reduce(data, %{}, fn github_issue, acc ->
      value = Map.get(github_issue, field)
      zenhub_estimate = github_issue["zenhub_estimate"] || 0
      current = Map.get(acc, value, get_default_pipeline_total())

      updated =
        current
        |> Map.update(:estimate_total, 0, &Artemis.Helpers.decimal_add(&1, zenhub_estimate))
        |> Map.update(:issue_total, 1, &(&1 + 1))

      case value do
        nil -> acc
        _ -> Map.put(acc, value, updated)
      end
    end)
  end

  @doc """
  Return default pipeline totals
  """
  def get_default_pipeline_total() do
    %{
      estimate_total: 0,
      issue_total: 0
    }
  end

  @doc """
  Return pipeline order
  """
  def get_zenhub_pipeline_order(github_issues) do
    github_issues
    |> Enum.map(&{Map.get(&1, "zenhub_pipeline"), Map.get(&1, "zenhub_pipeline_index")})
    |> Enum.uniq_by(&elem(&1, 0))
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.filter(&Artemis.Helpers.present?(elem(&1, 0)))
  end
end
