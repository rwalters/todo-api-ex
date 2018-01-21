defmodule Todo.ItemControllerTest do
  alias Todo.Cache

  use TodoWeb.ConnCase

  def with_valid_auth_token_header(conn) do
    Cache.start_link()
    Cache.setex("token.abcdef", 1, true)

    conn
    |> put_req_header("authorization", "Token token=\"abcdef\"")
  end

  def with_invalid_auth_token_header(conn) do
    conn
    |> put_req_header("authorization", "Token token=\"zyxwvut\"")
  end

  test "POST /lists/:list_id/items without authentication throws 401", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    payload = %{
      item: %{
        name: "Milk"
      }
    }

    conn =
      conn
      |> with_invalid_auth_token_header
      |> post("/api/lists/#{uuid}/items", payload)

    assert response(conn, 401) == "unauthorized"
  end

  test "POST /lists/:list_id/items with authentication creates item", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    payload = %{
      item: %{
        name: "Milk"
      }
    }

    conn =
      conn
      |> with_valid_auth_token_header
      |> post("/api/lists/#{list_id}/items", payload)

    %{"name" => "Milk", "id" => id, "src" => src} = json_response(conn, 201)
    assert src == "http://localhost:4000/lists/#{list_id}/items/#{id}"
  end

  test "POST /lists/:list_id/items for nonexistent list throws 404", %{conn: conn} do
    list_id = Ecto.UUID.generate()

    payload = %{
      item: %{
        name: "Milk"
      }
    }

    conn =
      conn
      |> with_valid_auth_token_header
      |> post("/api/lists/#{list_id}/items", payload)

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Item not found"}}
  end

  test "PUT /lists/:list_id/items/:id/finish without authentication throws 401", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"} = list} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Todo.Repo.insert(changeset)

    conn =
      conn
      |> with_invalid_auth_token_header
      |> put("/api/lists/#{list_id}/items/#{id}/finish")

    assert response(conn, 401) == "unauthorized"
  end

  test "PUT /lists/:list_id/items/:id/finish with authentication finishes item", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"} = list} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Todo.Repo.insert(changeset)

    conn =
      conn
      |> with_valid_auth_token_header
      |> put("/api/lists/#{list_id}/items/#{id}/finish")

    assert json_response(conn, 201) == "Milk finished"
  end

  test "PUT /lists/:list_id/items/:id/finish with nonexistent list throws 404", %{conn: conn} do
    list_id = Ecto.UUID.generate()
    id = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> put("/api/lists/#{list_id}/items/#{id}/finish")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Item not found"}}
  end

  test "PUT /lists/:list_id/items/:id/finish with nonexistent item throws 404", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    id = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> put("/api/lists/#{list_id}/items/#{id}/finish")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Item not found"}}
  end

  test "PUT /lists/:list_id/items/:id/finish with malformed list id throws 400", %{conn: conn} do
    list_id = "1234"
    id = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> put("/api/lists/#{list_id}/items/#{id}/finish")

    assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad request"}}
  end

  test "PUT /lists/:list_id/items/:id/finish with malformed item id throws 400", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    id = "1234"

    conn =
      conn
      |> with_valid_auth_token_header
      |> put("/api/lists/#{list_id}/items/#{id}/finish")

    assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad request"}}
  end

  test "DELETE /lists/:list_id/items/:id/finish without authentication throws 401", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"} = list} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Todo.Repo.insert(changeset)

    conn =
      conn
      |> with_invalid_auth_token_header
      |> delete("/api/lists/#{list_id}/items/#{id}")

    assert response(conn, 401) == "unauthorized"
  end

  test "DELETE /lists/:list_id/items/:id/finish with authentication deletes item", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"} = list} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Todo.Repo.insert(changeset)

    conn =
      conn
      |> with_valid_auth_token_header
      |> delete("/api/lists/#{list_id}/items/#{id}")

    assert response(conn, 204) == ""
  end

  test "DELETE /lists/:list_id/items/:id/finish with nonexistent list throws 404", %{conn: conn} do
    list_id = Ecto.UUID.generate()
    id = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> delete("/api/lists/#{list_id}/items/#{id}")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Item not found"}}
  end

  test "DELETE /lists/:list_id/items/:id/finish with nonexistent item throws 404", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    id = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> delete("/api/lists/#{list_id}/items/#{id}")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Item not found"}}
  end

  test "DELETE /lists/:list_id/items/:id/finish with malformed list id throws 400", %{conn: conn} do
    list_id = "1234"
    id = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> delete("/api/lists/#{list_id}/items/#{id}")

    assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad request"}}
  end

  test "DELETE /lists/:list_id/items/:id/finish with malformed item id throws 400", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}} =
      Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    id = "1234"

    conn =
      conn
      |> with_valid_auth_token_header
      |> delete("/api/lists/#{list_id}/items/#{id}")

    assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad request"}}
  end
end
