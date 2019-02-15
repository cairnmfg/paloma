defmodule Paloma.Broadcast do
  @moduledoc """
  An interface for broadcasting changes in Paloma resources.
  """

  @doc """
  Paloma.create/1, Paloma.update/2, and Paloma.delete/1 functions will
  trigger this function with the following arguments

  - the resource schema (eg `Paloma.Test.River`)
  - the change type as an atom (`:create`, `:delete`, or `:update`)
  - and the result of the change as a tuple (`{:ok, %Paloma.Test.River{}}` or `{:error, %Ecto.Changeset{}}`)

  The callback function can be overridden by applications using Paloma
  to build resources.

      defmodule CustomPublisher do
        require Logger

        @behaviour Paloma.Broadcast
        def broadcast(_schema, _change, result) do
          Logger.info("[Paloma] change received")
          result
        end
      end

      defmodule MyResource do
        use Paloma, broadcast: {CustomPublisher, :broadcast}, repo: Repo
      end
  """
  @type result_to_publish :: tuple()
  @callback broadcast(struct(), atom(), result_to_publish) :: result_to_publish
  def broadcast(_schema, _change, result), do: result
end
