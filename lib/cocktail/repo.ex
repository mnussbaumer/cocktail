defmodule Cocktail.Repo do
  use Ecto.Repo,
    otp_app: :cocktail,
    adapter: Ecto.Adapters.Postgres
end
