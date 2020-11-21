defmodule ParkingLot.ApiRouter do
  @moduledoc false
  require Logger
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  alias ParkingLot.Operations
  #################
  ### API paths ###
  #################

  post "/tickets" do
    Operations.create_parking_ticket()
    |> process_response(conn)
  end

  get "/alive" do
    send(conn, 200, 1)
  end

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
  defp error_codes(:no_free_parking_spaces), do: {400, "No free parking spaces"}
  defp error_codes(:not_found), do: {404, "Not found!"}
  defp error_codes(:db_error), do: {500, "DB error"}
  defp error_codes(_), do: {500, "Unknown error"}
end
