defmodule ParkingLot.ParkingFreeSpaces do
  @moduledoc false
  require Logger
  alias Database.InitDatabase

  def count() do
    case InitDatabase.init_parking_lot_status() do
      %{activ_parking_tickets: activ_parking_tickets} ->
        free_spaces =
          ParkingLot.parking_spaces()
          |> Kernel.-(activ_parking_tickets)

        {:ok, %{free_spaces: free_spaces}}

      _ ->
        {:error, :db_error}
    end
  end
end
