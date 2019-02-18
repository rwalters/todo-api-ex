defmodule TodoWeb.ListController do
  use TodoWeb, :controller

  alias Todo.{Repo, List}

  import TodoWeb.ErrorHelpers

  def index(conn, _params) do
    user = Todo.UserSession.current_user(conn)
    render(conn, "index.json", lists: user.lists)
  end

  def show(conn, %{"id" => list_id}) do
    with user <- Todo.UserSession.current_user(conn),
         list = %List{} <- find_list(user, list_id),
         list <- Repo.preload(list, :items) do
      render(conn, "show.json", list: list)
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn, "List not found")
    end
  end

  def create(conn, %{"list" => %{"name" => name}}) do
    with user <- Todo.UserSession.current_user(conn),
         {:ok, list} <- Todo.List.create(user, name: name) do
      conn
      |> put_status(201)
      |> render("create.json", list: list)
    else
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def update(conn, %{"id" => list_id, "list" => params}) do
    with user <- Todo.UserSession.current_user(conn),
         list = %List{} <- find_list(user, list_id),
         {:ok, updated} <- Todo.List.update(list, params) do
      conn
      |> put_status(201)
      |> render("update.json", list: updated)
    else
      nil -> not_found(conn, "List not found")
      :error -> malformed_request(conn)
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def delete(conn, %{"id" => list_id}) do
    with user <- Todo.UserSession.current_user(conn),
         list = %List{} <- find_list(user, list_id),
         {:ok, _list} <- Repo.delete(list) do
      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn, "List not found")
    end
  end

  defp find_list(user, id) do
    with {:ok, id} <- Ecto.UUID.cast(id) do
      Ecto.assoc(user, :lists)
      |> Repo.get(id)
    end
  end
end
