defmodule Paloma do
  @moduledoc """
  A shared query interface for CRUD operations operating on Ecto schema.
  """

  @doc false
  defmacro __using__(opts) do
    quote do
      @_broadcast unquote(opts)[:broadcast] || {Paloma.Broadcast, :broadcast}
      @_filters unquote(opts)[:filters] || []
      @_only unquote(opts)[:only] || [:create, :delete, :list, :retrieve, :update]
      @_repo unquote(opts)[:repo]
      @_schema unquote(opts)[:schema] || __MODULE__
      @_sorts unquote(opts)[:sorts] || []
      @before_compile unquote(__MODULE__)

      use Ecto.Schema
      import Ecto.Changeset
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    broadcast = Module.get_attribute(env.module, :_broadcast)
    filters = Module.get_attribute(env.module, :_filters)
    only = Module.get_attribute(env.module, :_only)
    repo = Module.get_attribute(env.module, :_repo)
    schema = Module.get_attribute(env.module, :_schema)
    sorts = Module.get_attribute(env.module, :_sorts)
    compile(broadcast, filters, only, repo, schema, sorts)
  end

  defp compile(broadcast, filters, only, repo, schema, sorts) do
    quote do
      def __paloma__(:broadcast), do: unquote(broadcast)
      def __paloma__(:filters), do: unquote(filters)
      def __paloma__(:functions), do: unquote(only)
      def __paloma__(:repo), do: unquote(repo)
      def __paloma__(:schema), do: unquote(schema)
      def __paloma__(:sorts), do: unquote(sorts)

      if :create in unquote(only) do
        def create(%{} = params) do
          unquote(schema)
          |> struct(%{})
          |> unquote(schema).changeset(params)
          |> unquote(repo).insert()
          |> broadcast(:create)
        end

        def create(_), do: {:error, :bad_request}
      end

      if :delete in unquote(only) do
        def delete(id) when is_binary(id) do
          case cast_id(id) do
            {:ok, id} -> delete(id)
            error -> error
          end
        end

        def delete(id) when is_integer(id) do
          case unquote(repo).get(unquote(schema), id) do
            %{__struct__: unquote(schema)} = resource ->
              delete(resource)

            _ ->
              {:error, :not_found}
          end
        end

        if List.first(unquote(filters)) do
          def delete(opts) when is_list(opts) do
            opts
            |> get_by_filters()
            |> case do
              %{__struct__: unquote(schema)} = resource -> delete(resource)
              _ -> {:error, :not_found}
            end
          end
        end

        def delete(%{__struct__: unquote(schema)} = resource) do
          resource
          |> unquote(repo).delete()
          |> broadcast(:delete)
        end

        def delete(_), do: {:error, :bad_request}
      end

      if :list in unquote(only) do
        def list(opts \\ []) do
          resources =
            unquote(schema)
            |> Paloma.Filter.call(unquote(filters), opts)
            |> Paloma.Sort.call(unquote(sorts), opts)
            |> unquote(repo).paginate(page: opts[:page], page_size: opts[:page_size])

          {:ok, resources}
        end
      end

      if :retrieve in unquote(only) do
        def retrieve(id) when is_binary(id) do
          case cast_id(id) do
            {:ok, id} -> retrieve(id)
            error -> error
          end
        end

        def retrieve(id) when is_integer(id) do
          case unquote(repo).get(unquote(schema), id) do
            %{__struct__: unquote(schema)} = resource -> {:ok, resource}
            _ -> {:error, :not_found}
          end
        end

        if List.first(unquote(filters)) do
          def retrieve(opts) when is_list(opts) do
            opts
            |> get_by_filters()
            |> case do
              %{__struct__: unquote(schema)} = resource -> {:ok, resource}
              nil -> {:error, :not_found}
              error -> error
            end
          end
        end

        def retrieve(_), do: {:error, :bad_request}
      end

      if :update in unquote(only) do
        def update(id, %{} = params) when is_binary(id) do
          case cast_id(id) do
            {:ok, id} -> update(id, params)
            error -> error
          end
        end

        def update(id, %{} = params) when is_integer(id) do
          case unquote(repo).get(unquote(schema), id) do
            %{__struct__: unquote(schema)} = resource ->
              update(resource, params)

            _ ->
              {:error, :not_found}
          end
        end

        if List.first(unquote(filters)) do
          def update(opts, %{} = params) when is_list(opts) do
            opts
            |> get_by_filters()
            |> case do
              %{__struct__: unquote(schema)} = resource -> update(resource, params)
              _ -> {:error, :not_found}
            end
          end
        end

        def update(%{__struct__: unquote(schema)} = resource, %{} = params) do
          resource
          |> unquote(schema).changeset(params)
          |> unquote(repo).update()
          |> broadcast(:update)
        end

        def update(_, _), do: {:error, :bad_request}
      end

      defp broadcast(result, change) do
        {module, function} = unquote(broadcast)
        apply(module, function, [unquote(schema), change, result])
      end

      defp cast_id(value) do
        case Integer.parse(value) do
          {int_value, _} -> {:ok, int_value}
          _ -> {:error, :bad_request}
        end
      end

      defp get_by_filters(opts) do
        try do
          unquote(schema)
          |> Paloma.Filter.call(unquote(filters), opts)
          |> unquote(repo).one()
        rescue
          _e -> {:error, :bad_request}
        end
      end
    end
  end
end
