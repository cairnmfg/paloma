defmodule Paloma.Filter do
  @moduledoc """
  An interface for building composable Ecto filter queries.
  """

  import Ecto.Query

  def call(query, fields, opts) do
    equal_to = extract_filters(opts, :equal_to, fields)
    greater_than = extract_filters(opts, :greater_than, fields)
    greater_than_or_equal_to = extract_filters(opts, :greater_than_or_equal_to, fields)
    less_than = extract_filters(opts, :less_than, fields)
    less_than_or_equal_to = extract_filters(opts, :less_than_or_equal_to, fields)
    not_equal_to = extract_filters(opts, :not_equal_to, fields)

    Enum.reduce(
      equal_to ++
        greater_than ++
        greater_than_or_equal_to ++ less_than ++ less_than_or_equal_to ++ not_equal_to,
      query,
      fn q, acc -> where(acc, ^q) end
    )
  end

  defp allowed?(fields, key), do: key in fields

  defp extract_filters(opts, type, fields) do
    opts
    |> sanitize(fields)
    |> filters_for(type)
    |> dynamic_query(type)
  end

  defp dynamic_query(filters, type)
       when type in [
              :equal_to,
              :greater_than,
              :greater_than_or_equal_to,
              :less_than,
              :less_than_or_equal_to,
              :not_equal_to
            ] do
    for {attr, values} <- filters, present?(values), do: dynamic_query(type, attr, values)
  end

  defp dynamic_query(:equal_to, attr, value)
       when is_binary(value) or is_boolean(value) or is_integer(value),
       do: dynamic([q], field(q, ^attr) == ^value)

  defp dynamic_query(:equal_to, attr, %NaiveDateTime{} = value),
    do: dynamic([q], field(q, ^attr) == ^value)

  defp dynamic_query(:equal_to, attr, values) when is_list(values),
    do: dynamic([q], field(q, ^attr) in ^values)

  defp dynamic_query(:equal_to, attr, value) when is_nil(value),
    do: dynamic([q], is_nil(field(q, ^attr)))

  defp dynamic_query(:greater_than, attr, value) when is_integer(value),
    do: dynamic([q], field(q, ^attr) > ^value)

  defp dynamic_query(:greater_than, attr, %NaiveDateTime{} = value),
    do: dynamic([q], field(q, ^attr) > ^value)

  defp dynamic_query(:greater_than_or_equal_to, attr, value) when is_integer(value),
    do: dynamic([q], field(q, ^attr) >= ^value)

  defp dynamic_query(:greater_than_or_equal_to, attr, %NaiveDateTime{} = value),
    do: dynamic([q], field(q, ^attr) >= ^value)

  defp dynamic_query(:less_than, attr, value) when is_integer(value),
    do: dynamic([q], field(q, ^attr) < ^value)

  defp dynamic_query(:less_than, attr, %NaiveDateTime{} = value),
    do: dynamic([q], field(q, ^attr) < ^value)

  defp dynamic_query(:less_than_or_equal_to, attr, value) when is_integer(value),
    do: dynamic([q], field(q, ^attr) <= ^value)

  defp dynamic_query(:less_than_or_equal_to, attr, %NaiveDateTime{} = value),
    do: dynamic([q], field(q, ^attr) <= ^value)

  defp dynamic_query(:not_equal_to, attr, value)
       when is_binary(value) or is_integer(value),
       do: dynamic([q], field(q, ^attr) != ^value)

  defp dynamic_query(:not_equal_to, attr, value) when is_boolean(value),
    do: dynamic([q], field(q, ^attr) != ^value or is_nil(field(q, ^attr)))

  defp dynamic_query(:not_equal_to, attr, %NaiveDateTime{} = value),
    do: dynamic([q], field(q, ^attr) != ^value or is_nil(field(q, ^attr)))

  defp dynamic_query(:not_equal_to, attr, values) when is_list(values),
    do: dynamic([q], field(q, ^attr) not in ^values)

  defp dynamic_query(:not_equal_to, attr, value) when is_nil(value),
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
  defp present?(value) when is_boolean(value), do: true
  defp present?(value) when is_integer(value), do: true
  defp present?(value) when is_nil(value), do: true
  defp present?(%NaiveDateTime{}), do: true
  defp present?(_), do: false

  defp sanitize(keyword_list, fields) do
    for({key, val} <- keyword_list, allowed?(fields, key), do: {key, val})
  end
end
