defmodule Database.InitDatabase do
  alias Database.Repo
  alias Database.ParkingLotStatus
  import Ecto.Query

  def init_parking_lot_status() do
    case Repo.exists?(ParkingLotStatus) do
      true ->
        Repo.one(from(x in ParkingLotStatus, order_by: [desc: x.id], limit: 1))

      false ->
        utc_time = DateTime.utc_now()

        parking_lot_status =
          ParkingLotStatus.changeset(%ParkingLotStatus{}, %{
            activ_parking_lot: 0,
            inserted_at: utc_time,
            updated_at: utc_time
          })

        case Repo.insert(parking_lot_status) do
          {:ok, response} -> response
          _ -> {:error, :db_error}
        end
    end
  end
end
