defmodule ParkingLot.ParkingLotStatusModel do
  @moduledoc false
  require Logger
  alias Database.InitDatabase
  alias Database.ParkingLotStatus

  ### Increment parking lot status model
  def increment(utc_time) do
    case InitDatabase.init_parking_lot_status() do
      %{activ_parking_tickets: activ_parking_tickets} = parking_lot_status ->
        parking_lot_status
        |> ParkingLotStatus.update_changeset(%{
          activ_parking_tickets: activ_parking_tickets + 1,
          updated_at: utc_time
        })
        |> is_valid()

      _ ->
        {:error, :db_error}
    end
  end

  ### Decrement parking lot status model
  def decrement(utc_time) do
    case InitDatabase.init_parking_lot_status() do
      %{activ_parking_tickets: activ_parking_tickets} = parking_lot_status ->
        parking_lot_status
        |> ParkingLotStatus.update_changeset(%{
          activ_parking_tickets: activ_parking_tickets - 1,
          updated_at: utc_time
        })
        |> is_valid()

      _ ->
        {:error, :db_error}
    end
  end

  ### Process parking lot status changeset
  defp is_valid(changeset) do
    case changeset.valid?() do
      true -> {:ok, changeset}
      false -> {:error, :no_free_parking_spaces}
    end
  end
end
