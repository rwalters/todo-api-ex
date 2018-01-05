defmodule Todo.ListControllerTest do
  use Todo.ConnCase

  def with_valid_auth_token_header(conn) do
    conn
    |> put_req_header("authorization", "Token token=\"abcdef\"")
  end

  def with_invalid_auth_token_header(conn) do
    conn
    |> put_req_header("authorization", "Token token=\"zyxwvut\"")
  end

  test "GET /api/lists without authentication throws 401", %{conn: conn} do
    conn = conn
           |> with_invalid_auth_token_header
           |> get("/api/lists")
    assert response(conn, 401) == "unauthorized"
  end

  test "GET /api/lists with authentication returns lists", %{conn: conn} do
    conn = conn
           |> with_valid_auth_token_header
           |> get("/api/lists")
    assert json_response(conn, 200) == %{"lists" => []}
  end
end
