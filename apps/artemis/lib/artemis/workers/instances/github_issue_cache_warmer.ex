defmodule Artemis.Worker.GithubIssueCacheWarmer do
  use Artemis.IntervalWorker,
    enabled: enabled?(),
    interval: :timer.seconds(60),
    delayed_start: :timer.seconds(15),
    name: :github_issue_cache_warmer

  # Callbacks

  @impl true
  def call(_data, _config) do
    tasks =
      Enum.map(get_github_repositories(), fn config ->
        organization = Keyword.get(config, :organization)
        repository = Keyword.get(config, :repository)

        Task.async(fn ->
          Artemis.Drivers.Github.ListRepoIssues.call_and_update_cache(organization, repository)
        end)
      end)

    {:ok, tasks}
  end

  # Helpers

  defp enabled?() do
    :artemis
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:github_issue_cache_warmer)
    |> Keyword.fetch!(:enabled)
    |> String.downcase()
    |> String.equivalent?("true")
  end

  defp get_github_repositories() do
    :artemis
    |> Application.fetch_env!(:github)
    |> Keyword.fetch!(:repositories)
  end
end
