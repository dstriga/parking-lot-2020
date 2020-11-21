use Mix.Config

config :parking_lot,
  port: {:system, "PORT", 8080, {String, :to_integer}}

import_config "#{Mix.env()}.exs"
