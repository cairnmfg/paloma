{:ok, _pid} = Paloma.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Paloma.Test.Repo, :manual)
ExUnit.start()
