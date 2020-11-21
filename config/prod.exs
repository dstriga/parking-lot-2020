use Mix.Config

config :parking_lot, port: String.to_integer(System.get_env("PORT") || "8080")

config :parking_lot, Database.Repo,
  ssl: true,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "15")

config :parking_lot, ecto_repos: [Database.Repo]
