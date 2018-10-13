defmodule Paloma.Filter do
  @moduledoc """
  An interface for building composable Ecto filter queries.
  """

  import Ecto.Query

  def call(query, fields, opts) do
    equal = extract_filters(opts, :equal, fields)
    not_equal = extract_filters(opts, :not_equal, fields)
    Enum.reduce(equal ++ not_equal, query, fn q, acc -> where(acc, ^q) end)
  end

  defp allowed?(fields, key), do: key in fields

  defp extract_filters(opts, type, fields) do
    opts
    |> sanitize(fields)
    |> filters_for(type)
    |> dynamic_query(type)
  end

  defp dynamic_query(filters, type) when type in [:equal, :not_equal] do
    for {attr, values} <- filters, present?(values), do: dynamic_query(type, attr, values)
  end

  defp dynamic_query(:equal, attr, value) when is_binary(value) or is_integer(value),
    do: dynamic([q], field(q, ^attr) == ^value)

  defp dynamic_query(:equal, attr, values) when is_list(values),
    do: dynamic([q], field(q, ^attr) in ^values)

  defp dynamic_query(:equal, attr, value) when is_nil(value),
    do: dynamic([q], is_nil(field(q, ^attr)))

  defp dynamic_query(:not_equal, attr, value) when is_binary(value) or is_integer(value),
    do: dynamic([q], field(q, ^attr) != ^value)

  defp dynamic_query(:not_equal, attr, values) when is_list(values),
    do: dynamic([q], field(q, ^attr) not in ^values)

  defp dynamic_query(:not_equal, attr, value) when is_nil(value),
    do: dynamic([q], not is_nil(field(q, ^attr)))

  defp filters_for(whitelisted_fields, type) do
    whitelisted_fields
    |> Enum.reduce([], fn {elem_k, elem_v}, acc ->
      match = for({elem_type, val} <- elem_v, type == elem_type, do: {elem_k, val})
      [match | acc]
    end)
    |> List.flatten()
  end

  defp present?(list) when is_list(list), do: length(list) > 0
  defp present?(value) when is_binary(value), do: String.length(value) > 0
  defp present?(value) when is_integer(value), do: true
  defp present?(value) when is_nil(value), do: true
  defp present?(_), do: false

  defp sanitize(keyword_list, fields) do
    for({key, val} <- keyword_list, allowed?(fields, key), do: {key, val})
  end
end
