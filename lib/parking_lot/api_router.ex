defmodule ParkingLot.ApiRouter do
  @moduledoc false
  require Logger
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  #################
  ### API paths ###
  #################

  get "/a" do
    send(conn, 200, "a")
  end

  match _ do
    send(conn, :not_found, "Not found!")
  end

  #######################
  ### Private methods ###
  #######################

  defp send(conn, code, data) when is_integer(code) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(code, Jason.encode!(data))
  end

  defp send(conn, code, data) when is_atom(code) do
    code =
      case code do
        :ok -> 200
        :not_found -> 404
        :malformed_data -> 400
        :non_authenticated -> 401
        :forbidden_access -> 403
        :server_error -> 500
        :error -> 504
      end

    send(conn, code, data)
  end
end
