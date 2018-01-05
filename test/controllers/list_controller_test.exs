defmodule Todo.ListControllerTest do
  use Todo.ConnCase
  require Exredis.Api

  def with_valid_auth_token_header(conn) do
    {:ok, client} = Exredis.start_link
    client |> Exredis.Api.setex("abcdef", 1, true)

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

  test "GET /api/list/:id without authentication throws 401", %{conn: conn} do
    {:ok, %{uuid: uuid, name: "Urgent Things"}} = Todo.Repo.insert(%Todo.List{name: "Urgent Things"})

    conn = conn
           |> with_invalid_auth_token_header
           |> get("/api/lists/#{uuid}")
    assert response(conn, 401) == "unauthorized"
  end

  test "GET /api/list/:id with authentication returns list", %{conn: conn} do
    {:ok, %{uuid: uuid, name: "Urgent Things"}} = Todo.Repo.insert(%Todo.List{name: "Urgent Things"})

    conn = conn
           |> with_valid_auth_token_header
           |> get("/api/lists/#{uuid}")
    %{"list" => %{"name" => "Urgent Things", "id" => id, "src" => _}} = json_response(conn, 200)
    assert uuid == id
  end

  test "POST /api/lists without authentication throws 401", %{conn: conn} do
    conn = conn
           |> with_invalid_auth_token_header
           |> post("/api/lists")
    assert response(conn, 401) == "unauthorized"
  end

  test "POST /api/lists with authentication creates list", %{conn: conn} do
    payload = %{
      list: %{
        name: "Urgent Things"
      }
    }
    conn = conn
           |> with_valid_auth_token_header
           |> post("/api/lists", payload)
    assert %{"name" => "Urgent Things", "id" => _, "src" => _} = json_response(conn, 201)
  end
end
