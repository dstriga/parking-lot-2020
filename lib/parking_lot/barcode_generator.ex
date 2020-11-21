defmodule ParkingLot.BarcodeGenerator do
  @moduledoc false
  require Logger
  @hex_digits "0123456789abcdef"

  # Get barcode
  def generate(length) when is_number(length) do
    :erlang.now() |> :random.seed()
    Enum.map_join(1..length, fn _ -> @hex_digits |> get_random_char() end)
  end

  # Get random_char
  def get_random_char(alphabet) do
    alphabet_length = alphabet |> String.length()
    get_random_char(alphabet, alphabet_length)
  end

  def get_random_char(alphabet, alphabet_length) do
    alphabet |> String.at(:random.uniform(alphabet_length) - 1)
  end
end
