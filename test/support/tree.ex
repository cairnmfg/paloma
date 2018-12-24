defmodule Paloma.Test.Tree do
  use Resource, filters: ~w(bark_color height id name native planted_at)a, sorts: ~w(id name)a

  schema "trees" do
    field(:bark_color, :string)
    field(:height, :integer)
    field(:name, :string)
    field(:native, :boolean)
    field(:planted_at, :naive_datetime)
    timestamps()
  end

  def changeset(%Paloma.Test.Tree{} = tree, attrs) do
    tree
    |> cast(attrs, [:bark_color, :height, :name, :native, :planted_at])
    |> validate_required([:name])
  end
end
