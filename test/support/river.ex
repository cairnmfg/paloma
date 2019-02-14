defmodule Paloma.Test.River do
  use Resource, broadcast: {Paloma.Test.Publisher, :broadcast}

  schema "rivers" do
    field(:name, :string)
    timestamps()
  end

  def changeset(%Paloma.Test.River{} = river, attrs) do
    river
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
