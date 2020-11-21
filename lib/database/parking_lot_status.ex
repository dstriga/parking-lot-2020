defmodule Database.ParkingLotStatus do
  use Ecto.Schema
  import Ecto.Changeset
  @min_value 0

  schema "parking_lot_status" do
    field(:activ_parking_tickets, :integer, default: @min_value)
    field(:inserted_at, :utc_datetime, null: false)
    field(:updated_at, :utc_datetime, null: false)
  end

  def changeset(data_model, params \\ %{}) do
    data_model
    |> cast(params, [:activ_parking_tickets, :inserted_at, :updated_at])
    |> validate_required([:activ_parking_tickets])
    |> validate_number(:activ_parking_tickets,
      greater_than_or_equal_to: @min_value,
      less_than_or_equal_to: ParkingLot.parking_spaces()
    )
  end
end
