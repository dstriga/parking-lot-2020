defmodule ParkingLot.Operations do
  @moduledoc false
  require Logger
  alias ParkingLot.ParkingTicket

  def create_parking_ticket() do
    ParkingTicket.create()
  end
end
