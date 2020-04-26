{:ok, _} = Application.ensure_all_started(:hound)

# configuration = ExUnit.configuration()
# excludes = Keyword.fetch!(configuration, :exclude)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Artemis.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(ArtemisLog.Repo, :manual)
