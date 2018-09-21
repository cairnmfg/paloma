defmodule Paloma.Test.Repo.Migrations.CreateTrees do
  use Ecto.Migration

  def change do
    create table(:trees) do
      add :bark_color, :string
      add :height, :integer
      add :name, :string
      timestamps()
    end
  end
end
