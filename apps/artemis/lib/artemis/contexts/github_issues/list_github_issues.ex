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
    |> filter_query(params, user)
  end

  defp get_records(_user) do
    repositories = [

    ]

    repositories
    |> Artemis.Drivers.Github.ListRepoIssues.call_with_cache()
    |> Map.get(:data)
  end

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

  defp filter(records, "number", value) do
    Enum.filter(records, &Enum.member?(split(value), Map.get(&1, "number")))
  end

  defp filter(records, "user", value) do
    Enum.filter(records, &Enum.member?(split(value), get_in(&1, ["user", "id"])))
  end

  defp filter(records, "zenhub_pipeline", value) do
    Enum.filter(records, &Enum.member?(split(value), Map.get(&1, "zenhub_pipeline")))
  end
end
