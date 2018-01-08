defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.{ErrorView, Repo, List, User}

  def index(conn, _params) do
    user = current_user(conn)
    render(conn, "index.json", lists: user.lists)
  end

  def show(conn, %{"id" => uuid}) do
    user = current_user(conn)
    with {:ok, uuid} <- Ecto.UUID.cast(uuid),
         list = %List{} <- assoc(user, :lists) |> Repo.get(uuid)
                |> Repo.preload(:items) do
      render(conn, "show.json", list: list)
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn)
    end
  end

  def create(conn, %{"list" => %{"name" => name}}) do
    with user <- current_user(conn),
         changeset = Ecto.build_assoc(user, :lists, name: name),
         {:ok, list} <- Repo.insert(changeset) do
      conn
      |> put_status(201)
      |> render("create.json", list: list)
    else
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def update(conn, %{"id" => uuid, "list" => params}) do
    with user <- current_user(conn),
         {:ok, uuid} <- Ecto.UUID.cast(uuid),
         list = %List{} <- assoc(user, :lists) |> Repo.get(uuid),
         changeset <- List.changeset(list, params),
         {:ok, updated} <- Repo.update(changeset) do
      conn
      |> put_status(201)
      |> render("update.json", list: updated)
    else
      nil -> errors(conn, ["List not found"])
      :error -> malformed_request(conn)
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with user <- current_user(conn),
         {:ok, uuid} <- Ecto.UUID.cast(uuid),
         list = %List{} <- assoc(user, :lists) |> Repo.get(uuid) do
      Repo.delete!(list)
      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn)
    end
  end

  defp current_user(conn) do
    user_id = Plug.Conn.get_session(conn, :user_id)
    Repo.get(User, user_id) |> Repo.preload(:lists)
  end

  defp malformed_request(conn) do
    conn
    |> put_status(400)
    |> render(ErrorView, "400.json", %{error: "Bad request"})
  end

  defp not_found(conn) do
    conn
    |> put_status(404)
    |> render(ErrorView, "404.json", %{error: "List not found"})
  end

  defp errors(conn, errors) do
    conn
    |> put_status(422)
    |> render(ErrorView, "422.json", %{errors: errors})
  end
end
