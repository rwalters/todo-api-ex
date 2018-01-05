defmodule BasicAuth do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, [username: username, password: password]) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> auth] ->
        conn
      _ ->
        conn
        |> send_resp(401, "unauthorized")
        |> halt
    end
  end
end
