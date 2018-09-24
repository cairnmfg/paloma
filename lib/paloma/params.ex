defmodule Paloma.Params do
  @moduledoc """
  A shared interface for converting map params into keyword list arguments
  supported by Paloma resources for filter and sort operations.
  """

  @doc """
  Parses a map of parameter inputs (most commonly in the context of an
  API endpoint) and converts those into a keyword list of arguments suited
  to Paloma.Filter and Paloma.Sort.

  Map inputs are whitelisted against a list of supported filter operations
  and sortable fields.
  """
  def convert(params, opts \\ []) do
    valid_filters = Keyword.get(opts, :filters, [])
    valid_sorts = Keyword.get(opts, :sorts, [])
    append_pagination = Keyword.get(opts, :paginate, true)

    params
    |> Enum.reduce([], fn {type, val}, acc ->
      operation =
        case type in supported_types(valid_filters) do
          true ->
            type
            |> String.to_atom()
            |> handle_param(val, valid_filters, valid_sorts)

          _ ->
            []
        end

      [operation | acc]
    end)
    |> List.flatten()
    |> Kernel.++(build_pagination(params, append_pagination))
  end

  defp build_pagination(params, true), do: [page: params["page"], page_size: params["size"]]
  defp build_pagination(_params, _), do: []

  defp extract_filter(key, instr, valid_filters) do
    supported_comparisons = valid_filters[key]

    filters =
      instr
      |> Enum.reduce([], fn {comparison, val}, acc ->
        filter =
          case comparison in supported_comparisons do
            true ->
              {String.to_atom(comparison), val}

            _ ->
              []
          end

        [filter | acc]
      end)
      |> List.flatten()

    {key, filters}
  end

  defp extract_sort(direction, field, valid_sorts) do
    valid_sorts = Enum.map(valid_sorts, fn n -> to_string(n) end)

    case Enum.member?(valid_sorts, field) do
      true -> [sort: {direction, String.to_atom(field)}]
      _ -> []
    end
  end

  defp handle_param(:sort, %{"asc" => field}, _valid_filters, valid_sorts),
    do: extract_sort(:asc, field, valid_sorts)

  defp handle_param(:sort, %{"desc" => field}, _valid_filters, valid_sorts),
    do: extract_sort(:desc, field, valid_sorts)

  defp handle_param(key, instr, valid_filters, _valid_sorts)
       when is_map(instr) and is_list(valid_filters) do
    case Enum.member?(Keyword.keys(valid_filters), key) do
      true ->
        extract_filter(key, instr, valid_filters)

      _ ->
        []
    end
  end

  defp supported_types(valid_filters) do
    valid_filters
    |> Keyword.keys()
    |> Kernel.++([:sort])
    |> Enum.map(fn f -> Atom.to_string(f) end)
  end
end
