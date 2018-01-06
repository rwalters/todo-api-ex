defmodule Todo.ItemController do
  use Todo.Web, :controller

  alias Todo.{Repo, List}
  alias Todo.{ErrorView, Repo, List}

  def create(conn, %{"list_id" => uuid, "item" => %{"name" => name}}) do
    with list = %List{} <- Repo.get(List, uuid),
         changeset = Ecto.build_assoc(list, :items, name: name),
      {:ok, item} <- Repo.insert(changeset) do

      conn
      |> put_status(201)
      |> render("show.json", item: item)
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", error: "Not found")
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end
end
