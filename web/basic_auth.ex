defmodule BasicAuth do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> auth] ->
        with user = %Todo.User{} <- Todo.Repo.get_by(Todo.User, encrypted_username_password: auth) do
          conn
          |> put_session(:user_id, user.id)
          |> assign(:current_user, user)
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
