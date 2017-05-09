use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :survey, Survey.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin"]]

# Watch static and templates for browser reloading.
config :survey, Survey.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :survey, Survey.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: "survey_dev",
  hostname: "localhost",
  pool_size: 10

config :ex_ami, 
  servers: [
    {:asterisk, [
      {:connection, {ExAmi.TcpConnection, [
        {:host, "0.0.0.0"}, {:port, 5038}
      ]}},
      {:username, "elixirconf"},
      {:secret, "elixirconf"}
    ]} ]

config :erlagi,
  listen: [
    {:localhost, host: '0.0.0.0', port: 20000, backlog: 5, callback: SpeakEx.CallController}
  ]
