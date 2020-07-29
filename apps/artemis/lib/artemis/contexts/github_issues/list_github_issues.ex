defmodule Artemis.ListGithubIssues do
  use Artemis.Context

  def call!(params \\ %{}, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error listing github issues")
      {:ok, result} -> result
    end
  end

  def call(_params \\ %{}, _user) do
    repositories = [
    ]

    result = Artemis.Drivers.Github.ListRepoIssues.call_with_cache(repositories)
  end
end
