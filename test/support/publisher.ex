defmodule  Paloma.Test.Publisher do
  @moduledoc false
  use Agent

  def start_link(_), do: Agent.start_link(fn -> [] end, name: __MODULE__)

  def get(), do: Agent.get(__MODULE__, fn state -> state end)

  def call(schema, change, result) do
    Agent.update(__MODULE__, fn state -> state ++ [{schema, change, result}] end)
    result
  end
end