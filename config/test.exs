use Mix.Config

config :logger, level: :warn

config :paloma, ecto_repos: [Paloma.Test.Repo]

config :paloma, Paloma.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "paloma_test",
  hostname: "localhost",
  database: "paloma_test",
  pool: Ecto.Adapters.SQL.Sandbox
