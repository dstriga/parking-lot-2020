defmodule ParkingLot.ParkingTicket do
  @moduledoc false
  require Logger
  alias Database.Repo
  alias ParkingLot.ParkingLotStatusModel
  alias Database.ParkingTicket
  alias ParkingLot.BarcodeGenerator
  require Enums.ParkingTicketStatus
  alias Enums.ParkingTicketStatus
  alias ParkingLot.ParkingTicketPrice

  ### Create new ticket
  def create() do
    utc_time = DateTime.utc_now() |> DateTime.truncate(:second)

    parking_ticket = %ParkingTicket{
      barcode: ParkingLot.barcode_length() |> BarcodeGenerator.generate(),
      start_time: utc_time,
      ticket_status: ParkingTicketStatus.activ()
    }

    utc_time
    |> ParkingLotStatusModel.get()
    |> execute_transaction(parking_ticket)
    |> process_transaction_response()
  end

  ### Calculate ticket price
  def calculate_price(barcode) do
    barcode
    |> get_parking_ticket()
    |> ParkingTicketPrice.calculate()
  end

  #######################
  ### Private methods ###
  #######################

  ### [DB] Get parking ticket by barcode
  defp get_parking_ticket(barcode) do
    case Repo.get_by(ParkingTicket, barcode: barcode) do
      nil -> {:error, :unknown_barcode}
      data -> {:ok, data}
    end
  end

  ### [DB] Execute transaction
  defp execute_transaction({:ok, parking_lot_status}, parking_ticket) do
    try do
      Repo.transaction(fn ->
        Repo.update!(parking_lot_status)
        Repo.insert!(parking_ticket)
      end)
    rescue
      _ -> {:error, :db_error}
    end
  end

  defp execute_transaction({:error, _} = error, _), do: error

  ### Process transaction response
  defp process_transaction_response(
         {:ok, %{barcode: barcode, start_time: start_time} = _parking_ticket}
       ) do
    {:ok, %{barcode: barcode, start_time: start_time}}
  end

  defp process_transaction_response(error), do: error
end
