defmodule Paloma.Test.Repo do
  use Ecto.Repo, otp_app: :paloma
  use Scrivener, page_size: 20
end
