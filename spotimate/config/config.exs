# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

import_config "secrets.exs"

config :spotimate,
  ecto_repos: [Spotimate.Repo]

# Configures the endpoint
config :spotimate, SpotimateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "r7tKqdVLrJGqtTvJ3Rk43iE1dBIyoSLxT6/1n/odgaGj60c4O/M2lB5TiH8DlO6l",
  render_errors: [view: SpotimateWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Spotimate.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
