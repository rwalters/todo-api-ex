defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.{Repo, List}
  alias Todo.{ErrorView, Repo, List}

  def index(conn, _params) do
    lists = Repo.all(List)
    render(conn, "index.json", lists: lists)
  end

  def show(conn, %{"id" => uuid}) do
    with list = %List{} <- Repo.get(List, uuid)
                |> Repo.preload(:items) do
      render(conn, "show.json", list: list)
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", error: "Not found")
    end
  end

  def create(conn, %{"list" => params}) do
    changeset = List.changeset(%List{}, params)

    with {:ok, list} <- Repo.insert(changeset) do
      conn
      |> put_status(201)
      |> render("create.json", list: list)
    else
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end

  def update(conn, %{"id" => uuid, "list" => params}) do
    with list = %List{} <- Repo.get(List, uuid),
      changeset = List.changeset(list, params),
      {:ok, updated} <- Repo.update(changeset) do
        conn
        |> put_status(201)
        |> render("update.json", list: updated)
    else
      nil ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: ["Failed to find record"]})
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with list = %List{} <- Repo.get(List, uuid) do
      Repo.delete!(list)
      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", error: "Not found")
    end
  end
end
