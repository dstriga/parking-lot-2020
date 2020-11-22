defmodule ParkingLot.UtilityDB do
  @moduledoc false
  require Logger
  alias Database.Repo

  ### [DB] Execute transaction
  def execute_transaction({:ok, update_record}, insert_record) do
    try do
      Repo.transaction(fn ->
        Repo.update!(update_record)
        Repo.insert!(insert_record)
      end)
    rescue
      _ -> {:error, :db_error}
    end
  end

  def execute_transaction({:error, _} = error, _), do: error
end
