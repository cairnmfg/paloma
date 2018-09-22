defmodule Paloma.Test.Tree do
  use Paloma, filters: ~w(bark_color height name)a, sorts: ~w(id name)a

  schema "trees" do
    field(:bark_color, :string)
    field(:height, :integer)
    field(:name, :string)
    timestamps()
  end

  def changeset(%Paloma.Test.Tree{} = tree, attrs) do
    tree
    |> cast(attrs, [:bark_color, :height, :name])
    |> validate_required([:name])
  end
end
