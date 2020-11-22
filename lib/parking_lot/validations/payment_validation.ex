defmodule Validations.PaymentValidation do
  @moduledoc false
  require Logger
  require Enums.PaymentOption
  alias Enums.PaymentOption

  ### Payment option
  def validate_payment_option(%{"payment_option" => data})
      when data in [PaymentOption.cash(), PaymentOption.credit_card(), PaymentOption.debit_card()] do
    {:ok, data}
  end

  def validate_payment_option(_), do: {:error, :invalid_payment_option}

  ### Payment value
  def validate_payment_value(%{"payment_value" => data}) when is_number(data) and data >= 0.0 do
    {:ok, data}
  end

  def validate_payment_value(_), do: {:error, :invalid_payment_value}
end
