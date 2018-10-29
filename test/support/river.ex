defmodule Paloma.Test.River do
  use Resource, broadcast_to: &Paloma.Test.Publisher.call/3

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
