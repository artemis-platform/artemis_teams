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
  end

  defp get_records(_user) do
    result = Artemis.Drivers.Github.ListRepoIssues.call_with_cache()

    Map.get(result, :data)
  end

  defp search_query(records, %{"query" => search}, _user) do
    regex = Regex.compile!(search, [:caseless])

    Enum.filter(records, fn record ->
      title = Map.get(record, "title")

      String.match?(title, regex)
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
end
