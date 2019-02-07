defmodule Todo.UserSession do
  alias Plug.Conn
  alias Todo.Repo

  def login_user(conn, user) do
    conn
    |> Conn.put_session(:user_id, user.id)
    |> Conn.assign(:current_user, user)
  end

  def logout(conn) do
    conn
    |> Conn.delete_session(:user_id)
    |> Conn.assign(:current_user, nil)
  end

  def current_user(conn) do
    conn.assigns[:current_user] || load_current_user(conn)
  end

  defp load_current_user(conn) do
    with id <- Conn.get_session(conn, :user_id),
         user <- Repo.get!(Todo.User, id) |> Repo.preload(:lists) do
      login_user(conn, user)

      user
    end
  end
end
