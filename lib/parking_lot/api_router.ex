defmodule ParkingLot.ApiRouter do
  @moduledoc false
  require Logger
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  alias Validations.{BarcodeValidation, PaymentValidation}

  alias ParkingLot.ParkingTicket
  alias ParkingLot.TicketPayment
  alias ParkingLot.TicketState
  alias ParkingLot.ParkingFreeSpaces

  #################
  ### API paths ###
  #################

  ### Task 1 - Create new parking ticket
  post "/tickets" do
    ParkingTicket.create()
    |> process_response(conn)
  end

  ### Task 2 - Calculate parking ticket price
  get "/tickets/:barcode" do
    case BarcodeValidation.validate(conn.params) do
      {:ok, data} ->
        data
        |> ParkingTicket.calculate_price()
        |> process_response(conn)

      error ->
        error |> process_response(conn)
    end
  end

  ### Task 3 - Payments
  post "/tickets/:barcode/payments" do
    case {BarcodeValidation.validate(conn.params),
          PaymentValidation.validate_payment_option(conn.params)} do
      {{:ok, barcode}, {:ok, payment_option}} ->
        barcode
        |> TicketPayment.process(payment_option)
        |> process_response(conn)

      _ ->
        {:error, :invalid_payment_format} |> process_response(conn)
    end
  end

  ### Task 4 - Parking ticket state
  get "/tickets/:barcode/state" do
    case BarcodeValidation.validate(conn.params) do
      {:ok, data} ->
        data
        |> TicketState.get()
        |> process_response(conn)

      error ->
        error |> process_response(conn)
    end
  end

  ### Task 5 - Parking free spaces
  get "/free-spaces" do
    ParkingFreeSpaces.count()
    |> process_response(conn)
  end

  ### Check app alive
  get "/alive" do
    send(conn, 200, 1)
  end

  ### Path not fount
  match _ do
    send(conn, 404, "Not found!")
  end

  #######################
  ### Private methods ###
  #######################

  defp process_response({:ok, data}, conn) do
    send(conn, 200, data)
  end

  defp process_response({:error, reason}, conn) do
    {error_code, error_data} = error_codes(reason)

    send(conn, error_code, error_data)
  end

  defp send(conn, code, data) when is_integer(code) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(code, Jason.encode!(data))
  end

  ### Error codes ###
  defp error_codes(:unknown_barcode), do: {400, "Unknown barcode"}
  defp error_codes(:invalid_payment_format), do: {400, "Invalid payment format"}
  defp error_codes(:invalid_barcode), do: {400, "Invalid barcode format"}
  defp error_codes(:no_free_parking_spaces), do: {400, "No free parking spaces"}
  defp error_codes(:not_found), do: {404, "Not found!"}
  defp error_codes(:db_error), do: {500, "DB error"}
  defp error_codes(_), do: {500, "Unknown error"}
end
