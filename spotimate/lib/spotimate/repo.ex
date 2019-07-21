defmodule Spotimate.Repo do
  use Ecto.Repo,
    otp_app: :spotimate,
    adapter: Ecto.Adapters.Postgres
end
