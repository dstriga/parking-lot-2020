defmodule Database.Repo.Migrations.CreateTicketPayments do
  use Ecto.Migration

  def change do
    create table(:ticket_payments) do
      add :payment_option, :string, null: false
      add :payment_time, :utc_datetime, default: nil
      add :payment_value, :float, default: 0.0
      add :parking_ticket_id, references(:parking_ticket)
    end
  end
end
