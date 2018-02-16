defmodule Todo.AuthenticationControllerTest do
  use TodoWeb.ConnCase

  def with_valid_authorization_header(conn) do
    Todo.Repo.delete_all(Todo.User)

    {:ok, _user} =
      Todo.Repo.insert(%Todo.User{encrypted_username_password: "dXNlcm5hbWU6cGFzc3dvcmQ="})

    conn
    |> put_req_header("authorization", "Basic dXNlcm5hbWU6cGFzc3dvcmQ=")
  end

  def with_invalid_authorization_header(conn) do
    conn
    |> put_req_header("authorization", "Basic notrealusernamepassword")
  end

  test "POST /api/authenticate without authentication throws 401", %{conn: conn} do
    conn = post(conn, "/api/authenticate")
    assert response(conn, 401) == "unauthorized"
  end

  test "POST /api/authenticate with invalid auth header throws 401", %{conn: conn} do
    conn =
      conn
      |> with_invalid_authorization_header
      |> post("/api/authenticate")

    assert response(conn, 401) == "unauthorized"
  end

  test "POST /api/authenticate with auth header is OK", %{conn: conn} do
    conn =
      conn
      |> with_valid_authorization_header
      |> post("/api/authenticate")

    assert %{"expires_at" => _, "token" => _} = json_response(conn, 200)
  end
end
