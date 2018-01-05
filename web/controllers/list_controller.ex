defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.{Repo, List}
  alias Todo.{ErrorView, Repo, List}
  alias Plug.Conn

  def index(conn, _params) do
    lists = Repo.all(List)
    render(conn, "index.json", lists: lists)
  end

  def show(conn, %{"id" => uuid}) do
    with list = %List{} <- Repo.get(List, uuid) do
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
      |> Conn.put_status(201)
      |> render("show.json", list: list)
    else
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end
end
