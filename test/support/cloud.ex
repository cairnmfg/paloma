defmodule Paloma.Test.Cloud do
  use Paloma, only: []

  schema "clouds" do
    field(:color, :string)
    field(:name, :string)
    timestamps()
  end

  def changeset(%Paloma.Test.Cloud{} = cloud, attrs) do
    cloud
    |> cast(attrs, [:color, :name])
    |> validate_required([:color, :name])
  end
end
