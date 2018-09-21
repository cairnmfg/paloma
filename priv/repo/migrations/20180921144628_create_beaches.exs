defmodule Paloma.Test.Repo.Migrations.CreateBeaches do
  use Ecto.Migration

  def change do
    create table(:beaches) do
      add :name, :string
      add :water, :string
      timestamps()
    end
  end
end
