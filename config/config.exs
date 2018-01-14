# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :todo, ecto_repos: [Todo.Repo]

# Configures the endpoint
config :todo, Todo.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QLNl4LEZFoKh3csCc0viYW76e34HowBHwvPe73zpeSqJSifDB4toMxwuFzwppxP9",
  render_errors: [view: Todo.ErrorView, accepts: ~w(json)],
  pubsub: [name: Todo.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger,
  backends: [:console, {LoggerFileBackend, :error_log}],
  format: "[$level] $message\n"

config :logger, :error_log,
  path: "/tmp/info.log",
  level: :debug

config :exredis,
  host: "127.0.0.1",
  password: "whatsup"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
