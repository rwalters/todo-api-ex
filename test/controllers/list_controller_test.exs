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
    {:ok, list_1} = Todo.Repo.insert(%Todo.List{name: "Shopping"})
    {:ok, list_2} = Todo.Repo.insert(%Todo.List{name: "Groceries"})

    conn = conn
           |> with_valid_auth_token_header
           |> get("/api/lists")
    assert json_response(conn, 200) == %{"lists" => [
      %{"id" => list_1.id, "name" => list_1.name, "src" => "http://localhost:4000/lists/#{list_1.id}"},
      %{"id" => list_2.id, "name" => list_2.name, "src" => "http://localhost:4000/lists/#{list_2.id}"},
    ]}
  end

  test "GET /api/list/:id without authentication throws 401", %{conn: conn} do
    {:ok, %{id: uuid, name: "Urgent Things"}} = Todo.Repo.insert(%Todo.List{name: "Urgent Things"})

    conn = conn
           |> with_invalid_auth_token_header
           |> get("/api/lists/#{uuid}")
    assert response(conn, 401) == "unauthorized"
  end

  test "GET /api/list/:id with authentication returns list", %{conn: conn} do
    {:ok, %{id: uuid, name: "Urgent Things"}} = Todo.Repo.insert(%Todo.List{name: "Urgent Things"})

    conn = conn
           |> with_valid_auth_token_header
           |> get("/api/lists/#{uuid}")
    %{"name" => "Urgent Things", "id" => id, "src" => _src, "items" => _items} = json_response(conn, 200)
    assert uuid == id
  end

  test "GET /api/list/:id with authentication returns list with items", %{conn: conn} do
    {:ok, %{id: uuid, name: "Urgent Things"}=list} = Todo.Repo.insert(%Todo.List{name: "Urgent Things"})
    changeset = Ecto.build_assoc(list, :items, name: "Buy Milk")
    Repo.insert(changeset)
    changeset = Ecto.build_assoc(list, :items, name: "Buy Onions")
    Repo.insert(changeset)

    conn = conn
           |> with_valid_auth_token_header
           |> get("/api/lists/#{uuid}")
    %{"name" => "Urgent Things", "id" => _id, "src" => _src, "items" => items} = json_response(conn, 200)
    assert Enum.map(items, &(&1["name"])) == ["Buy Milk", "Buy Onions"]
  end

  test "GET /api/list/:id with nonexistent list throws 404", %{conn: conn} do
    uuid = Ecto.UUID.generate()

    conn = conn
           |> with_valid_auth_token_header
           |> get("/api/lists/#{uuid}")
    assert json_response(conn, 404) == %{"errors" => %{"detail" => "List not found"}}
  end

  test "PATCH /api/lists/:id without authentication throws 401", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn = conn
           |> with_invalid_auth_token_header
           |> patch("/api/lists/#{uuid}", payload)
    assert response(conn, 401) == "unauthorized"
  end

  test "PATCH /api/lists/:id with authentication updates list", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn = conn
           |> with_valid_auth_token_header
           |> patch("/api/lists/#{uuid}", payload)
    assert json_response(conn, 201) == "Shopping List updated"
  end

  test "PATCH /api/lists/:id with nonexistent list throws 422", %{conn: conn} do
    uuid = Ecto.UUID.generate()

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn = conn
           |> with_valid_auth_token_header
           |> patch("/api/lists/#{uuid}", payload)
    assert json_response(conn, 422) == %{"errors" => %{"detail" => "Bad request"}}
  end

  test "DELETE /api/lists/:id without authentication throws 401", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    conn = conn
           |> with_invalid_auth_token_header
           |> delete("/api/lists/#{uuid}")
    assert response(conn, 401) == "unauthorized"
  end

  test "DELETE /api/lists/:id with authentication updates list", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    conn = conn
           |> with_valid_auth_token_header
           |> delete("/api/lists/#{uuid}")
    assert response(conn, 204) == ""
  end

  test "POST /api/lists without authentication throws 401", %{conn: conn} do
    payload = %{
      list: %{
        name: "Urgent Things"
      }
    }
    conn = conn
           |> with_invalid_auth_token_header
           |> post("/api/lists", payload)
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
