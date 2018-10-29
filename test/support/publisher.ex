defmodule Paloma.Test.Publisher do
  @moduledoc false
  use Agent
  @behaviour Paloma.Broadcast

  def start_link(_), do: Agent.start_link(fn -> [] end, name: __MODULE__)

  def get(), do: Agent.get(__MODULE__, fn state -> state end)

  def broadcast(schema, change, result) do
    Agent.update(__MODULE__, fn state -> state ++ [{schema, change, result}] end)
    result
  end
end
