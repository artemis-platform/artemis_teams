defmodule Artemis.Worker.GithubIssueCacheWarmer do
  use Artemis.IntervalWorker,
    enabled: enabled?(),
    interval: :timer.seconds(60),
    delayed_start: :timer.seconds(15),
    name: :github_issue_cache_warmer

  # Callbacks

  @impl true
  def call(_data, _config) do
    task =
      Task.async(fn ->
        Artemis.Drivers.Github.ListRepoIssues.call_and_update_cache()
      end)

    {:ok, task}
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
end
