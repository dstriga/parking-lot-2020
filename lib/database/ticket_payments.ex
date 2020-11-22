defmodule Database.TicketPayments do
  use Ecto.Schema
  import Ecto.Changeset
  require Enums.PaymentOption
  alias Enums.PaymentOption

  schema "ticket_payments" do
    belongs_to(:parking_ticket, Database.ParkingTicket)
    field(:payment_option, :string, default: nil)
    field(:payment_time, :utc_datetime, default: :utc_datetime)
    field(:payment_value, :float, default: 0.0)
  end

  def changeset(data_model, params \\ %{}) do
    data_model
    |> cast(params, [:payment_option, :payment_time, :payment_value])
    |> validate_required([:payment_option, :payment_time, :payment_value])
    |> validate_number(:payment_value, greater_than_or_equal_to: 0.0)
    |> validate_subset(:payment_option, [
      PaymentOption.cash(),
      PaymentOption.credit_card(),
      PaymentOption.debit_card()
    ])
  end
end
