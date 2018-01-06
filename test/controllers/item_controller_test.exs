defmodule Todo.ItemControllerTest do
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

  test "POST /lists/:list_id/items without authentication throws 401", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    payload = %{
      item: %{
        name: "Milk"
      }
    }
    conn = conn
           |> with_invalid_auth_token_header
           |> post("/api/lists/#{uuid}/items", payload)
    assert response(conn, 401) == "unauthorized"
  end

  test "POST /lists/:list_id/items with authentication creates item", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    payload = %{
      item: %{
        name: "Milk"
      }
    }
    conn = conn
           |> with_valid_auth_token_header
           |> post("/api/lists/#{list_id}/items", payload)
    %{"name" => "Milk", "id" => id, "src" => src} = json_response(conn, 201)
    assert src == "http://localhost:4000/lists/#{list_id}/items/#{id}"
  end

  test "PUT /lists/:list_id/items/:id/finish without authentication throws 401", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}=list} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})
    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Repo.insert(changeset)

    conn = conn
           |> with_invalid_auth_token_header
           |> put("/api/lists/#{list_id}/items/#{id}/finish")
    assert response(conn, 401) == "unauthorized"
  end

  test "PUT /lists/:list_id/items/:id/finish with authentication finishes item", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}=list} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})
    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Repo.insert(changeset)

    conn = conn
           |> with_valid_auth_token_header
           |> put("/api/lists/#{list_id}/items/#{id}/finish")
    %{"name" => "Milk", "id" => _id, "src" => _src, "finished_at" => finished_at} = json_response(conn, 201)
    assert finished_at != nil
  end

  test "DELETE /lists/:list_id/items/:id/finish without authentication throws 401", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}=list} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})
    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Repo.insert(changeset)

    conn = conn
           |> with_invalid_auth_token_header
           |> delete("/api/lists/#{list_id}/items/#{id}")
    assert response(conn, 401) == "unauthorized"
  end

  test "DELETE /lists/:list_id/items/:id/finish with authentication finishes item", %{conn: conn} do
    {:ok, %{id: list_id, name: "Grocery List"}=list} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})
    changeset = Ecto.build_assoc(list, :items, name: "Milk")
    {:ok, %{id: id}} = Repo.insert(changeset)

    conn = conn
           |> with_valid_auth_token_header
           |> delete("/api/lists/#{list_id}/items/#{id}")
    assert response(conn, 204) == ""
  end
end
