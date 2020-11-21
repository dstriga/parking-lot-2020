defmodule ParkingLot do
  @moduledoc false
  require Logger
  use Application

  def start(_type, _args) do
    ParkingLot.Supervisor.start_link()
  end


  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ParkingLot.Router,
        options: [port: port()]
      )
    ]

    Logger.debug("Router started at #{port()}")
    Supervisor.init(children, strategy: :one_for_one)
  end

  def port, do: Application.get_env(:parking_lot, :port, 8000)


end
