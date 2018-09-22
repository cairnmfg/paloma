defmodule Paloma.Sort do
  @moduledoc """
  An interface for ordering Ecto queries for Paloma resources.
  """

  import Ecto.Query, only: [order_by: 2]

  @doc false
  def call(query, fields, opts) do
    opts
    |> extract()
    |> validate(fields)
    |> build(query)
  end

  defp build(sort, query) when length(sort) == 0, do: order_by(query, desc: :id)
  defp build(sort, query), do: order_by(query, ^sort)

  defp extract(opts) do
    for({key, val} <- opts, key == :sort, do: val) |> List.flatten()
  end

  defp validate(sort, fields) do
    for(
      {direction, field} <- sort,
      direction in [:asc, :desc] and field in fields,
      do: {direction, field}
    )
  end
end
