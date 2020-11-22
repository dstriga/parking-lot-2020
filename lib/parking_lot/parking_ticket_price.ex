defmodule ParkingLot.ParkingTicketPrice do
  @moduledoc false
  require Logger

  ### Process DB responde and calculate ticket price
  def calculate({:ok, %{start_time: start_time} = _parking_ticket}) do
    utc_time = DateTime.utc_now() |> DateTime.truncate(:second)

    diff_min_time =
      utc_time
      |> DateTime.diff(start_time)
      |> Kernel./(60.0)

    ticket_price =
      Float.ceil(diff_min_time / ParkingLot.parking_price_duration_min(), 0)
      |> Kernel.*(ParkingLot.parking_price_value())
      |> Float.round(ParkingLot.parking_price_decimal_places())

    {:ok,
     %{
       ticket_price_value: ticket_price,
       ticket_price_currency: ParkingLot.parking_price_currency(),
       ticket_price_time: utc_time
     }}
  end

  def calculate({:error, _} = error), do: error
end
