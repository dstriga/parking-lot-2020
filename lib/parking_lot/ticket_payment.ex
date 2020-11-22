defmodule ParkingLot.TicketPayment do
  @moduledoc false
  require Logger
  alias Database.ParkingTicket
  alias Database.TicketPayments

  alias ParkingLot.ParkingTicket, as: ParkingTicketMethods
  alias ParkingLot.ParkingTicketPrice
  require Enums.ParkingTicketStatus
  alias Enums.ParkingTicketStatus
  alias ParkingLot.UtilityDB

  def process(barcode, payment_option) do
    case ParkingTicketMethods.get_parking_ticket(barcode) do
      {:ok, %{ticket_status: _} = parking_ticket} ->
        parking_ticket
        |> ParkingTicketPrice.calculate()
        |> process_parking_ticket_price(parking_ticket, payment_option)

      error ->
        error
    end
  end

  #######################
  ### Private methods ###
  #######################

  ### [Parking ticket price] Process
  defp process_parking_ticket_price(
         {:ok, %{ticket_price_value: ticket_price_value}},
         parking_ticket,
         payment_option
       )
       when is_number(ticket_price_value) and ticket_price_value > 0 do
    ticket_payment = %TicketPayments{
      payment_option: payment_option,
      payment_value: ticket_price_value,
      parking_ticket: parking_ticket,
      payment_time: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    {:ok,
     parking_ticket
     |> ParkingTicket.update_status_changeset(%{ticket_status: ParkingTicketStatus.paid()})}
    |> UtilityDB.execute_transaction(ticket_payment)
    |> process_transaction_response()
  end

  defp process_parking_ticket_price({:ok, _}, _, _), do: {:ok, :ticket_paid}
  defp process_parking_ticket_price({:error, _} = error, _, _), do: error

  ### [DB] ### Process transaction response
  defp process_transaction_response(
         {:ok,
          %{
            payment_option: payment_option,
            payment_time: payment_time,
            payment_value: payment_value
          }}
       ) do
    {:ok,
     %{payment_option: payment_option, payment_time: payment_time, payment_value: payment_value}}
  end

  defp process_transaction_response(error), do: error
end
