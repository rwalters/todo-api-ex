defmodule Todo.ListControllerTest do
  use Todo.ConnCase

  def with_valid_authorization_header(conn) do
    conn
    |> put_req_header("authorization", "Basic dXNlcm5hbWU6cGFzc3dvcmQ=")
  end

  test "GET /api/lists without authentication throws 401", %{conn: conn} do
    conn = get conn, "/api/lists"
    assert response(conn, 401) == "unauthorized"
  end

  test "GET /api/lists with auth header is OK", %{conn: conn} do
    conn = conn
           |> with_valid_authorization_header
           |> get "/api/lists"
    assert json_response(conn, 200) == %{"lists" => []}
  end
end
