defmodule ParkingLot.Operations do
  @moduledoc false
  require Logger
  alias ParkingLot.ParkingTicket

  def create_parking_ticket() do
    ParkingTicket.create()
  end

  def calculate_parking_ticket_price(barcode) do
    barcode |> ParkingTicket.calculate_price()
  end
end
