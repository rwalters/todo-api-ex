defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.{ErrorView, Repo, List}

  def index(conn, _params) do
    lists = Repo.all(List)
    render(conn, "index.json", lists: lists)
  end

  def show(conn, %{"id" => uuid}) do
    with {:ok, uuid} <- Ecto.UUID.cast(uuid),
         list = %List{} <- Repo.get(List, uuid)
                |> Repo.preload(:items) do
      render(conn, "show.json", list: list)
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn)
    end
  end

  def create(conn, %{"list" => params}) do
    changeset = List.changeset(%List{}, params)

    with {:ok, list} <- Repo.insert(changeset) do
      conn
      |> put_status(201)
      |> render("create.json", list: list)
    else
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def update(conn, %{"id" => uuid, "list" => params}) do
    with {:ok, uuid} <- Ecto.UUID.cast(uuid),
         list = %List{} <- Repo.get(List, uuid),
      changeset = List.changeset(list, params),
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
    with {:ok, uuid} <- Ecto.UUID.cast(uuid),
         list = %List{} <- Repo.get(List, uuid) do
      Repo.delete!(list)
      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn)
    end
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
