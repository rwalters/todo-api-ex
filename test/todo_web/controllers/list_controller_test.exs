defmodule TodoWeb.ListControllerTest do
  alias Todo.Cache

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

  def create_user(username \\ "something", password \\ "password") do
    with {:ok, user} <-
           Todo.Repo.insert(%Todo.User{
             encrypted_username_password: Todo.User.encode(username, password)
           }) do
      user
    end
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

  test "GET /api/lists with authentication returns lists for current user", %{conn: conn} do
    user = create_user()
    list_1 = create_list(user, name: "Shopping")
    list_2 = create_list(user, name: "Groceries")

    different_user = create_user("nobody")
    _list_3 = create_list(different_user, name: "Movies")
    _list_4 = create_list(different_user, name: "TV Shows")

    conn =
      conn
      |> with_valid_auth_token_header(user)
      |> get("/api/lists")

    assert json_response(conn, 200) == %{
             "lists" => [
               %{
                 "id" => list_2.id,
                 "name" => list_2.name,
                 "src" => "http://localhost:4000/lists/#{list_2.id}"
               },
               %{
                 "id" => list_1.id,
                 "name" => list_1.name,
                 "src" => "http://localhost:4000/lists/#{list_1.id}"
               }
             ]
           }
  end

  test "POST /api/lists without authentication throws 401", %{conn: conn} do
    payload = %{
      list: %{
        name: "Urgent Things"
      }
    }

    conn =
      conn
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

    conn =
      conn
      |> with_valid_auth_token_header
      |> post("/api/lists", payload)

    assert %{"name" => "Urgent Things", "id" => _, "src" => _} = json_response(conn, 201)
  end

  test "POST /api/lists with duplicate name ", %{conn: conn} do
    (user = create_user()) |> create_list(name: "Shopping")

    payload = %{
      list: %{
        name: "Shopping"
      }
    }

    conn =
      conn
      |> with_valid_auth_token_header(user)
      |> post("/api/lists", payload)

    assert json_response(conn, 422) == %{"name" => ["has already been taken"]}
  end

  test "GET /api/list/:id without authentication throws 401", %{conn: conn} do
    list = create_user() |> create_list(name: "Shopping")

    conn =
      conn
      |> with_invalid_auth_token_header
      |> get("/api/lists/#{list.id}")

    assert response(conn, 401) == "unauthorized"
  end

  test "GET /api/list/:id with authentication returns list", %{conn: conn} do
    list = (user = create_user()) |> create_list(name: "Shopping")

    conn =
      conn
      |> with_valid_auth_token_header(user)
      |> get("/api/lists/#{list.id}")

    %{"name" => "Shopping", "id" => id, "src" => _src, "items" => _items} =
      json_response(conn, 200)

    assert list.id == id
  end

  test "GET /api/list/:id with authentication returns list with items", %{conn: conn} do
    list = (user = create_user()) |> create_list(name: "Shopping")
    Ecto.build_assoc(list, :items, name: "Buy Milk") |> Todo.Repo.insert()
    Ecto.build_assoc(list, :items, name: "Buy Onions") |> Todo.Repo.insert()

    conn =
      conn
      |> with_valid_auth_token_header(user)
      |> get("/api/lists/#{list.id}")

    %{"name" => "Shopping", "id" => _id, "src" => _src, "items" => items} =
      json_response(conn, 200)

    assert Enum.map(items, & &1["name"]) == ["Buy Milk", "Buy Onions"]
  end

  test "GET /api/list/:id returns 404 for list that doesn't belong to user", %{conn: conn} do
    list = (_user = create_user()) |> create_list(name: "Shopping")
    different_user = create_user("nobody")

    conn =
      conn
      |> with_valid_auth_token_header(different_user)
      |> get("/api/lists/#{list.id}")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "List not found"}}
  end

  test "GET /api/list/:id with nonexistent list throws 404", %{conn: conn} do
    uuid = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> get("/api/lists/#{uuid}")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "List not found"}}
  end

  test "GET /api/list/:id with malformed list id throws 400", %{conn: conn} do
    uuid = "1234"

    conn =
      conn
      |> with_valid_auth_token_header
      |> get("/api/lists/#{uuid}")

    assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad request"}}
  end

  test "PATCH /api/lists/:id without authentication throws 401", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn =
      conn
      |> with_invalid_auth_token_header
      |> patch("/api/lists/#{uuid}", payload)

    assert response(conn, 401) == "unauthorized"
  end

  test "PATCH /api/lists/:id with authentication updates list", %{conn: conn} do
    user = create_user()
    list = create_list(user, name: "Shopping")

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn =
      conn
      |> with_valid_auth_token_header(user)
      |> patch("/api/lists/#{list.id}", payload)

    assert json_response(conn, 201) == "Shopping List updated"
  end

  test "PATCH /api/lists/:id returns 404 for someone else's list", %{conn: conn} do
    list = (_user = create_user()) |> create_list(name: "Shopping")
    different_user = create_user("nobody")

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn =
      conn
      |> with_valid_auth_token_header(different_user)
      |> patch("/api/lists/#{list.id}", payload)

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "List not found"}}
  end

  test "PATCH /api/lists/:id with nonexistent list throws 404", %{conn: conn} do
    uuid = Ecto.UUID.generate()

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn =
      conn
      |> with_valid_auth_token_header
      |> patch("/api/lists/#{uuid}", payload)

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "List not found"}}
  end

  test "PATCH /api/lists/:id with malformed list id throws 400", %{conn: conn} do
    uuid = "1234"

    payload = %{
      list: %{
        name: "Shopping List"
      }
    }

    conn =
      conn
      |> with_valid_auth_token_header
      |> patch("/api/lists/#{uuid}", payload)

    assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad request"}}
  end

  test "DELETE /api/lists/:id without authentication throws 401", %{conn: conn} do
    {:ok, %{id: uuid, name: "Grocery List"}} = Todo.Repo.insert(%Todo.List{name: "Grocery List"})

    conn =
      conn
      |> with_invalid_auth_token_header
      |> delete("/api/lists/#{uuid}")

    assert response(conn, 401) == "unauthorized"
  end

  test "DELETE /api/lists/:id with authentication deletes list", %{conn: conn} do
    list = (user = create_user()) |> create_list(name: "Shopping")

    conn =
      conn
      |> with_valid_auth_token_header(user)
      |> delete("/api/lists/#{list.id}")

    assert response(conn, 204) == ""
  end

  test "DELETE /api/lists/:id returns 404 for someone else's list", %{conn: conn} do
    list = (_user = create_user("nobody")) |> create_list(name: "Shopping")
    different_user = create_user("somebody")

    conn =
      conn
      |> with_valid_auth_token_header(different_user)
      |> delete("/api/lists/#{list.id}")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "List not found"}}
  end

  test "DELETE /api/lists/:id with nonexistent list throws 404", %{conn: conn} do
    uuid = Ecto.UUID.generate()

    conn =
      conn
      |> with_valid_auth_token_header
      |> delete("/api/lists/#{uuid}")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "List not found"}}
  end

  test "DELETE /api/lists/:id with malformed list id throws 400", %{conn: conn} do
    uuid = "1234"

    conn =
      conn
      |> with_valid_auth_token_header
      |> delete("/api/lists/#{uuid}")

    assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad request"}}
  end
end
