defmodule Paloma.Test.Beach do
  use Paloma

  schema "beaches" do
    field(:name, :string)
    field(:water, :string)
    timestamps()
  end

  def changeset(%Paloma.Test.Beach{} = beach, attrs) do
    beach
    |> cast(attrs, [:name, :water])
    |> validate_required([:name])
  end
end
