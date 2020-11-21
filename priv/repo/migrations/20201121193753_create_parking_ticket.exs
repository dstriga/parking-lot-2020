defmodule Database.Repo.Migrations.CreateParkingTicket do
  use Ecto.Migration

  def change do
    create table(:parking_ticket) do
      add :barcode, :string, null: false
      add :start_time, :utc_datetime, default: nil
      add :end_time, :utc_datetime, default: nil
      add :ticket_status, :integer, default: 0
    end

    create unique_index(:parking_ticket, [:barcode])
    create index(:parking_ticket, [:ticket_status])
  end
end
