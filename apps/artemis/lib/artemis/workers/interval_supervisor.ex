defmodule Artemis.IntervalSupervisor do
  use Supervisor

  @moduledoc """
  Starts and supervises interval workers.
  """

  def start_link(options \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: options[:name] || __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {Artemis.Worker.GithubIssueCacheWarmer, []},
      {Artemis.Worker.IBMCloudIAMAccessToken, []},
      {Artemis.Worker.KeyValueCleaner, []},
      {Artemis.Worker.RepoResetOnInterval, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    options = [strategy: :one_for_one]

    Supervisor.init(children, options)
  end
end
