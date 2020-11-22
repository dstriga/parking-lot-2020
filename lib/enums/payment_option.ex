defmodule Enums.PaymentOption do
  @moduledoc false

  defmacro credit_card do
    quote do: "credit_card"
  end

  defmacro debit_card do
    quote do: "debit_card"
  end

  defmacro cash do
    quote do: "cash"
  end
end
