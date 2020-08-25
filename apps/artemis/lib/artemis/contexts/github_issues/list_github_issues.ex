defmodule Artemis.ListGithubIssues do
  use Artemis.Context

  import Artemis.Helpers.Filter

  def call!(params \\ %{}, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error listing github issues")
      {:ok, result} -> result
    end
  end

  def call(params \\ %{}, user) do
    params = Artemis.Helpers.keys_to_strings(params)

    user
    |> get_records()
    |> search_query(params, user)
    |> filter_query(params, user)
    |> sort_records(params)
  end

  defp get_records(_user) do
    result = Artemis.Drivers.Github.ListRepoIssues.call_with_cache()

    Map.get(result, :data)
  end

  defp search_query(records, %{"query" => search}, _user) do
    regex = Regex.compile!(search, [:caseless])

    Enum.filter(records, fn record ->
      title = Map.get(record, "title")

      issue_number =
        record
        |> Map.get("number")
        |> Integer.to_string()

      String.match?(title, regex) || search == issue_number
    end)
  rescue
    _e in Regex.CompileError -> records
  end

  defp search_query(records, _params, _user), do: records

  defp filter_query(records, %{"filters" => filters}, _user) when is_map(filters) do
    Enum.reduce(filters, records, fn {key, value}, acc ->
      filter(acc, key, value)
    end)
  end

  defp filter_query(records, _params, _user), do: records

  defp filter(records, "assignee", value) do
    Enum.filter(records, fn record ->
      assignees =
        record
        |> Map.get("assignees")
        |> Enum.map(&Map.get(&1, "login"))

      Enum.any?(split(value), &Enum.member?(assignees, &1))
    end)
  end

  defp filter(records, "created_at_gte", ""), do: records

  defp filter(records, "created_at_gte", value) do
    timestamp =
      value
      |> Timex.parse!("{YYYY}-{0M}-{0D}")
      |> Timex.to_unix()

    Enum.filter(records, fn record ->
      created_at =
        record
        |> Map.get("created_at")
        |> Timex.parse!("{ISO:Extended:Z}")
        |> Timex.to_unix()

      created_at >= timestamp
    end)
  rescue
    _ -> records
  end

  defp filter(records, "created_at_lt", ""), do: records

  defp filter(records, "created_at_lt", value) do
    timestamp =
      value
      |> Timex.parse!("{YYYY}-{0M}-{0D}")
      |> Timex.to_unix()

    Enum.filter(records, fn record ->
      created_at =
        record
        |> Map.get("created_at")
        |> Timex.parse!("{ISO:Extended:Z}")
        |> Timex.to_unix()

      created_at < timestamp
    end)
  rescue
    _ -> records
  end

  defp filter(records, "has_comments", value) do
    case value do
      "true" -> Enum.filter(records, &(Map.get(&1, "comments") > 0))
      "false" -> Enum.filter(records, &(Map.get(&1, "comments") == 0))
      _ -> records
    end
  end

  defp filter(records, "has_zenhub_estimate", value) do
    case value do
      "true" -> Enum.filter(records, &Map.get(&1, "zenhub_estimate"))
      "false" -> Enum.reject(records, &Map.get(&1, "zenhub_estimate"))
      _ -> records
    end
  end

  defp filter(records, "is_epic", value) do
    case value do
      "true" -> Enum.filter(records, &(Map.get(&1, "zenhub_epic") == true))
      "false" -> Enum.filter(records, &(Map.get(&1, "zenhub_epic") == false))
      _ -> records
    end
  end

  defp filter(records, "labels", value) do
    Enum.filter(records, fn record ->
      labels =
        record
        |> Map.get("labels")
        |> Enum.map(&Map.get(&1, "name"))

      Enum.all?(split(value), &Enum.member?(labels, &1))
    end)
  end

  defp filter(records, "labels_not", value) do
    Enum.reject(records, fn record ->
      labels =
        record
        |> Map.get("labels")
        |> Enum.map(&Map.get(&1, "name"))

      Enum.any?(split(value), &Enum.member?(labels, &1))
    end)
  end

  defp filter(records, "milestone", value) do
    Enum.filter(records, fn record ->
      milestone = Artemis.Helpers.deep_get(record, ["milestone", "title"])

      Enum.member?(split(value), milestone)
    end)
  end

  defp filter(records, "number", value) do
    Enum.filter(records, &Enum.member?(split(value), Map.get(&1, "number")))
  end

  defp filter(records, "organization", value) do
    Enum.filter(records, &Enum.member?(split(value), Map.get(&1, "organization")))
  end

  defp filter(records, "repository", value) do
    Enum.filter(records, &Enum.member?(split(value), Map.get(&1, "repository")))
  end

  defp filter(records, "user", value) do
    Enum.filter(records, &Enum.member?(split(value), get_in(&1, ["user", "id"])))
  end

  defp filter(records, "zenhub_pipeline", value) do
    Enum.filter(records, &Enum.member?(split(value), Map.get(&1, "zenhub_pipeline")))
  end

  defp sort_records(records, _params) do
    Enum.sort_by(records, fn record ->
      [
        Map.get(record, "zenhub_pipeline_index"),
        Map.get(record, "number")
      ]
    end)
  end
end
