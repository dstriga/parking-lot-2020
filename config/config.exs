use Mix.Config

config :parking_lot, Database.Repo,
  database: "parking_lot_repo",
  username: "darko",
  password: "darko!!88",
  hostname: "localhost"

config :parking_lot, ecto_repos: [Database.Repo]

config :parking_lot,
  port: {:system, "PORT", 8080, {String, :to_integer}},
  parking_spaces: 54,
  barcode_length: 16,
  parking_price_value: 2.00,
  parking_price_currency: "€",
  parking_price_duration_min: 60,
  parking_price_decimal_places: 2,
  parking_free_min_time: 15

import_config "#{Mix.env()}.exs"
