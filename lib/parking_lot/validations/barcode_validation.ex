defmodule Validations.BarcodeValidation do
  @moduledoc false
  require Logger

  def validate(%{"barcode" => data}) when is_binary(data) and not is_nil(data) do
    if String.length(data) == ParkingLot.barcode_length() do
      {:ok, data}
    else
      {:error, :invalid_barcode}
    end
  end

  def validate(_), do: {:error, :invalid_barcode}
end
