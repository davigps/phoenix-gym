defmodule Phoenixgym.Repo do
  use Ecto.Repo,
    otp_app: :phoenixgym,
    adapter: Ecto.Adapters.Postgres
end
