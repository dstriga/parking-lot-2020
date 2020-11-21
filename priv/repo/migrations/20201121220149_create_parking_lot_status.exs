defmodule Database.Repo.Migrations.CreateParkingLotStatus do
  use Ecto.Migration

  def change do
    create table(:parking_lot_status) do
      add :activ_parking_tickets, :integer, default: 0

      timestamps()
    end
  end
end

