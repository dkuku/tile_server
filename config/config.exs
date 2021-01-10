# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :tile_server, TileServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XUgpYQQW12iGu1bLzLfTgJxGfgS1bx2ILuuWLvQ4X/wCNMeEeUd+vP2yXX0Bz0ul",
  render_errors: [view: TileServerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: TileServer.PubSub,
  live_view: [signing_salt: "JLOovgbF"]

#config :mbtiles, :mbtiles_path, "priv/united_kingdom.mbtiles"
config :mbtiles, :mbtiles_path, "priv/poland_katowice.mbtiles"
#config :mbtiles, :mbtiles_path, 'priv/test.mbtiles'


#config :mbtiles, mbtiles_path: "priv/poland_katowice.mbtiles"
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
