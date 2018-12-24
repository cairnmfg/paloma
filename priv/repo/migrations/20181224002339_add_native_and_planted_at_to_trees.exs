defmodule Paloma.Test.Repo.Migrations.AddNativeAndPlantedAtToTrees do
  use Ecto.Migration

  def change do
    alter table(:trees) do
      add :native, :boolean
      add :planted_at, :naive_datetime
    end
  end
end
