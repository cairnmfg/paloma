defmodule Paloma.Test.Repo.Migrations.CreateClouds do
  use Ecto.Migration

  def change do
    create table(:clouds) do
      add :color, :string
      add :name, :string
      timestamps()
    end
  end
end
