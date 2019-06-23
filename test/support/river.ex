defmodule Paloma.Test.River do
  use Resource, broadcast: {Paloma.Test.Publisher, :broadcast}, filters: ~w(tags)a

  schema "rivers" do
    field(:name, :string)
    field(:tags, {:array, :string})
    timestamps()
  end

  def changeset(%Paloma.Test.River{} = river, attrs) do
    river
    |> cast(attrs, [:name, :tags])
    |> validate_required([:name])
  end
end
