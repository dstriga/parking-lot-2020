defmodule ParkingLot.ParkingTicket do
  @moduledoc false
  require Logger
  alias Database.Repo
  alias Database.InitDatabase
  alias Database.{ParkingTicket, ParkingLotStatus}
  alias ParkingLot.BarcodeGenerator
  require Enums.ParkingTicketStatus
  alias Enums.ParkingTicketStatus

  def create() do
    utc_time = DateTime.utc_now() |> DateTime.truncate(:second)

    parking_ticket = %ParkingTicket{
      barcode: ParkingLot.barcode_length() |> BarcodeGenerator.generate(),
      start_time: utc_time,
      ticket_status: ParkingTicketStatus.activ()
    }

    utc_time
    |> get_parking_lot_status()
    |> execute_transaction(parking_ticket)
    |> process_transaction_response()
  end

  ### Execute DB transaction
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

  ### Get parking lot status model
  defp get_parking_lot_status(utc_time) do
    case InitDatabase.init_parking_lot_status() do
      %{activ_parking_tickets: activ_parking_tickets} = parking_lot_status ->
        parking_lot_status
        |> ParkingLotStatus.changeset(%{
          activ_parking_tickets: activ_parking_tickets + 1,
          inserted_at: utc_time,
          updated_at: utc_time
        })
        |> process_parking_lot_status()

      _ ->
        {:error, :db_error}
    end
  end

  ### Process parking lot status changeset
  defp process_parking_lot_status(changeset) do
    case changeset.valid?() do
      true -> {:ok, changeset}
      false -> {:error, :no_free_parking_spaces}
    end
  end
end
