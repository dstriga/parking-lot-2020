defmodule Database.ParkingTicket do
  use Ecto.Schema
  import Ecto.Changeset
  require Enums.ParkingTicketStatus
  alias Enums.ParkingTicketStatus

  schema "parking_ticket" do
    field(:barcode, :string, null: false)
    field(:start_time, :utc_datetime, default: nil)
    field(:end_time, :utc_datetime, default: nil)
    field(:ticket_status, :integer, default: 0)
    has_many(:ticket_payments, Database.TicketPayments)
  end

  def changeset(data_model, params \\ %{}) do
    data_model
    |> cast(params, [:barcode, :start_time, :end_time, :ticket_status])
    |> validate_required([:barcode, :start_time, :end_time, :ticket_status])
    |> validate_length(:barcode, is: ParkingLot.barcode_length())
    |> validate_inclusion(:ticket_status, [
      ParkingTicketStatus.unpaid(),
      ParkingTicketStatus.returned(),
      ParkingTicketStatus.paid()
    ])
  end

  def update_status_changeset(data_model, params \\ %{}) do
    data_model
    |> cast(params, [:ticket_status])
    |> validate_required([:ticket_status])
    |> validate_inclusion(:ticket_status, [
      ParkingTicketStatus.unpaid(),
      ParkingTicketStatus.returned(),
      ParkingTicketStatus.paid()
    ])
  end
end
