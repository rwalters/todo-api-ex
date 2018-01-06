defmodule Todo.ItemController do
  use Todo.Web, :controller

  alias Todo.{Repo, List, Item}
  alias Todo.{ErrorView, Repo, List, Item}

  def create(conn, %{"list_id" => list_id, "item" => %{"name" => name}}) do
    with list = %List{} <- Repo.get(List, list_id),
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

  def finish(conn, %{"list_id" => _list_id, "id" => id}) do
    with item = %Item{} <- Repo.get(Item, id),
      changeset = Item.changeset(item, %{finished_at: DateTime.utc_now}),
      {:ok, updated} <- Repo.update(changeset) do
        conn
        |> put_status(201)
        |> render("show.json", item: updated)
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

  def delete(conn, %{"list_id" => _list_id, "id" => id}) do
    with item = %Item{} <- Repo.get(Item, id) do
      Repo.delete!(item)
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
