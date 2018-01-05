defmodule TokenAuth do
  import Plug.Conn
  require Exredis.Api

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Token token=" <> token] ->
        if find_token(token) do
          conn
        else
          unauthorized(conn)
        end
      _ ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> send_resp(401, "unauthorized")
    |> halt
  end

  defp find_token(token) do
    token = String.replace(token, ~r/"/, "")
    {:ok, client} = Exredis.start_link

    client
    |> Exredis.Api.get(token)
    |> case do
      :undefined ->
        false
      _ ->
        true
    end
  end
end
