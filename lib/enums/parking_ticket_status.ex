defmodule Enums.ParkingTicketStatus do
  @moduledoc false

  defmacro activ do
    quote do: 0
  end

  defmacro returned do
    quote do: 1
  end
end
