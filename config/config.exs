# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cocktail,
  ecto_repos: [Cocktail.Repo]

# Configures the endpoint
config :cocktail, CocktailWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "768Pc3q2GR6/xOScjRIQ97oHeDtwFYdrlvlU88YgAnqOTvUQyx5w+VaB4bLH9rDd",
  render_errors: [view: CocktailWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cocktail.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "cocktail_salt"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
