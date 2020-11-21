use Mix.Config

config :parking_lot, port: String.to_integer(System.get_env("PORT") || "8080")
