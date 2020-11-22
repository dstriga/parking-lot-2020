defmodule ParkingLot.ParkingTicketPrice do
  @moduledoc false
  require Logger
  require Enums.ParkingTicketStatus
  alias Enums.ParkingTicketStatus
  alias ParkingLot.TicketPayment

  ### Process DB responde and calculate ticket price
  def calculate(
        {:ok, %{id: id, start_time: start_time, ticket_status: ticket_status} = _parking_ticket}
      ) do
    id
    |> get_latest_ticket_time(start_time)
    |> process(ticket_status)
  end

  def calculate(%{id: id, start_time: start_time, ticket_status: ticket_status}) do
    id
    |> get_latest_ticket_time(start_time)
    |> process(ticket_status)
  end

  def calculate({:error, _} = error), do: error

  #######################
  ### Private methods ###
  #######################

  ### [Latest ticket time] Get
  defp get_latest_ticket_time(parking_ticket_id, start_time) do
    parking_ticket_id
    |> TicketPayment.get_latest_ticket_payment()
    |> process_latest_ticket_time(start_time)
  end

  ### [Latest ticket time] Process
  defp process_latest_ticket_time([%{payment_time: payment_time} | _], start_time)
       when payment_time > start_time,
       do: payment_time

  defp process_latest_ticket_time([], start_time), do: start_time
  defp process_latest_ticket_time(_, _), do: {:error, :db_error}

  ### [Ticket price] Process calculation
  defp process(start_time, ticket_status) when ticket_status == ParkingTicketStatus.unpaid() do
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

  defp process(_, _) do
    {:ok,
     %{
       ticket_price_value: 0.0,
       ticket_price_currency: ParkingLot.parking_price_currency(),
       ticket_price_time: DateTime.utc_now() |> DateTime.truncate(:second)
     }}
  end
end
