defmodule ParkingLot.MixProject do
  use Mix.Project

  def project do
    [
      app: :parking_lot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ParkingLot, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, "~> 0.15.7"},
      {:poison, "~> 4.0"}
    ]
  end
end
