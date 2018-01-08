defmodule TokenAuth do
  import Plug.Conn
  require Exredis.Api

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Token token=" <> token] ->
        if user_id = find_token(token) do
          conn
          |> Plug.Conn.put_session(:user_id, user_id)
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
    user_id = Exredis.Api.get(client ,token)

    case user_id do
      :undefined -> false
      _ -> user_id
    end
  end
end
