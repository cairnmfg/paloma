defmodule Paloma.MixProject do
  use Mix.Project

  def project() do
    [
      app: :paloma,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases() do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  defp deps() do
    [
      # A toolkit for data mapping and language integrated query for Elixir
      {:ecto, "~> 3.0"},
      # SQL-based adapters for Ecto and database migrations
      {:ecto_sql, "~> 3.0"},
      # Automatically run your Elixir project's tests each time you save a file
      {:mix_test_watch, "~> 0.8", only: :test, runtime: false},
      # PostgreSQL driver for Elixir
      {:postgrex, "~> 0.14.1"},
      # Paginate your Ecto queries with Scrivener
      {:scrivener_ecto, "~> 2.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
