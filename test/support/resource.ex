defmodule Resource do
  @moduledoc false
  defmacro __using__(opts \\ []) do
    quote do
      use Paloma, unquote(opts) ++ [repo: Paloma.Test.Repo]
    end
  end
end
