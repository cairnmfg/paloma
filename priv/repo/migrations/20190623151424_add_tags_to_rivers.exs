defmodule Paloma.Test.Repo.Migrations.AddTagsToRivers do
  use Ecto.Migration

  def up do
    alter table(:rivers) do
      add :tags, {:array, :text}, default: "{}"
    end

    execute "CREATE INDEX rivers_tags_index ON rivers USING gin (tags);"
  end

  def down do
    alter table(:rivers) do
      remove :tags
    end

    execute "DROP INDEX rivers_tags_index;"
  end
end
