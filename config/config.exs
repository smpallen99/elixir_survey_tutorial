# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :survey, Survey.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "KidRAQbxAff4inlAjVzvwWgeJRadqLJ45dWVMumvyuef4/bVW+pLPFE4sf+ML/Tt",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Survey.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_admin, 
  repo: Survey.Repo,
  module: Survey,
  modules: [
    Survey.ExAdmin.Dashboard,
    Survey.ExAdmin.Survey,
    Survey.ExAdmin.Question,
    Survey.ExAdmin.Choice,
    Survey.ExAdmin.Seating,
  ]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :phoenix, :template_engines,
    haml: PhoenixHaml.Engine,
    eex: Phoenix.Template.EExEngine

config :xain, :quote, "'"
config :xain, :after_callback, &Phoenix.HTML.raw/1

config :speak_ex, :renderer, :swift

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
