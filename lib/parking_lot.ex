defmodule ParkingLot do
  @moduledoc false
  require Logger
  use Application

  def start(_type, _args) do
    bootstrap()
    ParkingLot.Supervisor.start_link()
  end

  defp bootstrap do
    Logger.debug("Starting application")
  end

  def parking_spaces, do: Application.fetch_env!(:parking_lot, :parking_spaces)

  def barcode_length, do: Application.fetch_env!(:parking_lot, :barcode_length)

  def parking_price_value, do: Application.fetch_env!(:parking_lot, :parking_price_value)
  def parking_price_currency, do: Application.fetch_env!(:parking_lot, :parking_price_currency)

  def parking_price_duration_min,
    do: Application.fetch_env!(:parking_lot, :parking_price_duration_min)

    def parking_price_decimal_places,
    do: Application.fetch_env!(:parking_lot, :parking_price_decimal_places)


end
