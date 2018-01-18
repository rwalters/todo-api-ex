defmodule Todo.ListControllerTest do
  use TodoWeb.ConnCase

  def with_valid_auth_token_header(conn), do: with_valid_auth_token_header(conn, create_user())

  def with_valid_auth_token_header(conn, user) do
    token = Ecto.UUID.generate()
    Cache.start_link()
    Cache.setex("token.#{token}", 1, user.id)

    conn
    |> assign(:user_id, user.id)
    |> put_req_header("authorization", "Token token=\"#{token}\"")
  end

  def with_invalid_auth_token_header(conn) do
    conn
    |> put_req_header("authorization", "Token token=\"#{Ecto.UUID.generate()}\"")
  end

  def create_user(username \\ "username", password \\ "password") do
    with {:ok, user} <-
           Todo.Repo.insert(%Todo.User{
             encrypted_username_password: Todo.User.encode(username, password)
           }),
         do: user
  end

  def create_list(user, name: name) do
    with {:ok, list} = Ecto.build_assoc(user, :lists, name: name) |> Todo.Repo.insert(), do: list
  end

  test "GET /api/lists without authentication throws 401", %{conn: conn} do
    conn =
      conn
      |> with_invalid_auth_token_header
      |> get("/api/lists")

    assert response(conn, 401) == "unauthorized"
  end
end
