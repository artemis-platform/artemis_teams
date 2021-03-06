defmodule Artemis.Worker.RepoResetOnInterval do
  use Artemis.IntervalWorker,
    enabled: enabled?(),
    interval: get_interval(),
    delayed_start: :timer.seconds(10),
    name: :repo_reset_on_interval

  alias Artemis.Repo.DeleteAll
  alias Artemis.Repo.GenerateData
  alias Artemis.Repo.GenerateFillerData

  # Callbacks

  @impl true
  def call(_data, _config) do
    with {:ok, _} <- DeleteAll.call(DeleteAll.verification_phrase()),
         {:ok, _} <- GenerateData.call(),
         {:ok, _} <- GenerateFillerData.call(GenerateFillerData.verification_phrase()) do
      {:ok, true}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  # Helpers

  defp enabled?() do
    Artemis.Helpers.AppConfig.all_enabled?([
      [:artemis, :umbrella, :background_workers],
      [:artemis, :actions, :repo_reset_on_interval]
    ])
  end

  defp get_interval() do
    hours =
      Application.fetch_env!(:artemis, :actions)
      |> Keyword.get(:repo_reset_on_interval)
      |> Keyword.get(:interval)
      |> String.to_integer()

    hours * 60 * 60 * 1000
  end
end
