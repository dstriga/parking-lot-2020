defmodule Enums.ParkingTicketStatus do
  @moduledoc false

  defmacro unpaid do
    quote do: 0
  end

  defmacro returned do
    quote do: 1
  end

  defmacro paid do
    quote do: 2
  end
end
