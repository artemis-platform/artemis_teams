{:ok, _} = Application.ensure_all_started(:ex_machina)

# configuration = ExUnit.configuration()
# excludes = Keyword.fetch!(configuration, :exclude)

ExUnit.configure(exclude: [pending: true])
ExUnit.start()

Artemis.Repo.GenerateData.call()
Ecto.Adapters.SQL.Sandbox.mode(Artemis.Repo, :manual)
