defmodule BasicAuth do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> auth] ->
        with %Todo.User{} <- Todo.Repo.get_by(Todo.User, encrypted_username_password: auth) do
          conn
        else
          nil ->
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
end
