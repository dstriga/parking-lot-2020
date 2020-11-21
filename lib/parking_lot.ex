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
end
