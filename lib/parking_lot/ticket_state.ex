defmodule ParkingLot.TicketState do
  @moduledoc false
  require Logger
  require Enums.ParkingTicketStatus
  alias Enums.ParkingTicketStatus
  alias Database.Repo
  alias Database.ParkingTicket
  alias ParkingLot.ParkingLotStatusModel
  alias ParkingLot.TicketPayment
  alias ParkingLot.ParkingTicket, as: ParkingTicketMethods

  def get(barcode) do
    barcode
    |> ParkingTicketMethods.get_parking_ticket()
    |> process_parking_ticket()
  end

  #######################
  ### Private methods ###
  #######################

  ### Process parking ticket status
  ### Returned parking ticket
  defp process_parking_ticket({:ok, %{ticket_status: ticket_status} = _parking_ticket})
       when ticket_status == ParkingTicketStatus.returned() do
    {:ok, :ticket_paid_and_returned}
  end

  ### Unpaind parking ticket
  defp process_parking_ticket({:ok, %{ticket_status: ticket_status} = _parking_ticket})
       when ticket_status == ParkingTicketStatus.unpaid() do
    {:ok, :ticket_unpaid}
  end

  ### Paind parking ticket
  defp process_parking_ticket(
         {:ok, %{id: ticket_id, ticket_status: ticket_status} = parking_ticket}
       )
       when ticket_status == ParkingTicketStatus.paid() do
    ticket_id
    |> TicketPayment.get_latest_ticket_payment()
    |> calculate_ticket_state(parking_ticket)
  end

  ### Error
  defp process_parking_ticket({:error, _} = error), do: error

  ### Calculate ticket state
  defp calculate_ticket_state(
         [%{payment_time: payment_time} | _],
         %{start_time: start_time} = parking_ticket
       ) do
    utc_time = DateTime.utc_now() |> DateTime.truncate(:second)

    paid_time =
      payment_time
      |> DateTime.diff(start_time)
      |> Kernel./(60.0)
      |> Kernel./(ParkingLot.parking_price_duration_min())
      |> Float.ceil(0)

    actual_time =
      utc_time
      |> DateTime.diff(start_time)
      |> Kernel./(60.0)
      |> Kernel./(ParkingLot.parking_price_duration_min())
      |> Float.ceil(0)

    diff_paid_min_time =
      utc_time
      |> DateTime.diff(payment_time)
      |> Kernel./(60.0)

    parking_ticket
    |> process_ticket_state(paid_time, actual_time, diff_paid_min_time, utc_time)
  end

  ### Process ticket state
  defp process_ticket_state(parking_ticket, paid_time, actual_time, _diff_paid_min_time, utc_time)
       when paid_time >= actual_time do
    parking_ticket |> update_ticket_state(ParkingTicketStatus.returned(), utc_time)
  end

  defp process_ticket_state(
         parking_ticket,
         _paid_time,
         _actual_time,
         diff_paid_min_time,
         utc_time
       ) do
    if diff_paid_min_time < ParkingLot.parking_free_min_time() do
      parking_ticket |> update_ticket_state(ParkingTicketStatus.returned(), utc_time)
    else
      parking_ticket |> update_ticket_state(ParkingTicketStatus.unpaid(), utc_time)
    end
  end

  ### [Update][Ticket state] to... returned
  defp update_ticket_state(parking_ticket, new_ticket_state, utc_time)
       when new_ticket_state == ParkingTicketStatus.returned() do
    update_parking_ticket =
      parking_ticket
      |> ParkingTicket.update_time_status_changeset(%{
        ticket_status: new_ticket_state,
        end_time: utc_time
      })

    utc_time
    |> ParkingLotStatusModel.decrement()
    |> ParkingLot.UtilityDB.execute_update_transaction(update_parking_ticket)
    |> process_response(new_ticket_state)
  end

  ### [Update][Ticket state] to... unpaid
  defp update_ticket_state(parking_ticket, new_ticket_state, _utc_time)
       when new_ticket_state == ParkingTicketStatus.unpaid() do
    parking_ticket
    |> ParkingTicket.update_status_changeset(%{ticket_status: new_ticket_state})
    |> Repo.update()
    |> process_response(new_ticket_state)
  end

  ### Process response
  defp process_response({:ok, _}, ticket_state)
       when ticket_state in [ParkingTicketStatus.returned(), ParkingTicketStatus.paid()],
       do: {:ok, :ticket_paid}

  defp process_response({:ok, _}, ticket_state)
       when ticket_state in [ParkingTicketStatus.unpaid()],
       do: {:ok, :ticket_unpaid}

  defp process_response({:error, _} = error, _), do: error
  defp process_response(_, _), do: {:error, :db_error}
end
