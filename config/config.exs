use Mix.Config

config :parking_lot, Database.Repo,
  database: "parking_lot_repo",
  username: "darko",
  password: "darko!!88",
  hostname: "localhost"

config :parking_lot, ecto_repos: [Database.Repo]

config :parking_lot,
  port: {:system, "PORT", 8080, {String, :to_integer}},
  parking_spaces: 10,
  barcode_length: 16

import_config "#{Mix.env()}.exs"
