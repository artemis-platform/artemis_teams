defmodule ArtemisWeb.GithubIssueView do
  use ArtemisWeb, :view

  def data_table_available_columns() do
    [
      {"Assignee", "assignee"},
      {"Labels", "labels"},
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
      "labels" => [
        label: fn _conn -> "Labels" end,
        value: fn _conn, row ->
          Enum.map(row["labels"], fn label ->
            href = String.replace(label["url"], "/api/v3/repos", "")
            color = label["color"]

            content_tag(:div) do
              content_tag(:a, label["name"],
                href: href,
                style:
                  "background: ##{color}; color: #fff; display: inline-block; margin: 0 2px 3px 0; padding: 2px 8px; border-radius: 3px;",
                target: "_blank"
              )
            end
          end)
        end
      ],
      "number" => [
        label: fn _conn -> "Number" end,
        value: fn _conn, row -> row["number"] end
      ],
      "title" => [
        label: fn _conn -> "Title" end,
        value: fn _conn, row -> row["title"] end
      ],
      "zenhub_pipeline" => [
        label: fn _conn -> "Pipeline" end,
        value: fn _conn, row -> row["zenhub_pipeline"] end
      ]
    }
  end
end
