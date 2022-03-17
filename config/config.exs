# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :salsa_crm,
  ecto_repos: [SalsaCrm.Repo]

# Configures the endpoint
config :salsa_crm, SalsaCrmWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "goQK0rte0jzQ9DkZGuQofrmK57FnPhWocaD9yopHHjVYAxnu5LwBBT+UPMcT8uj5",
  render_errors: [view: SalsaCrmWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: MsCrm.PubSub
  # live_view: [signing_salt: "lHOngcjI"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
