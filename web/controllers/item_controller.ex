defmodule Todo.ItemController do
  use Todo.Web, :controller

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
        |> render(ErrorView, "404.json", %{error: "Resource not found"})
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end

  def finish(conn, %{"list_id" => list_id, "id" => id}) do
    with {:ok, list_id} <- Ecto.UUID.cast(list_id),
         {:ok, id} <- Ecto.UUID.cast(id),
         %List{} <- Repo.get(List, list_id),
         item = %Item{} <- Repo.get(Item, id),
         changeset = Item.changeset(item, %{finished_at: DateTime.utc_now}),
      {:ok, updated} <- Repo.update(changeset) do
        conn
        |> put_status(201)
        |> render("show.json", item: updated)
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", %{error: "Resource not found"})
      :error ->
        conn
        |> put_status(400)
        |> render(ErrorView, "400.json", %{error: "Bad request"})
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end

  def delete(conn, %{"list_id" => list_id, "id" => id}) do
    with {:ok, list_id} <- Ecto.UUID.cast(list_id),
         {:ok, id} <- Ecto.UUID.cast(id),
         %List{} <- Repo.get(List, list_id),
         item = %Item{} <- Repo.get(Item, id) do
      Repo.delete!(item)
      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", %{error: "Resource not found"})
      :error ->
        conn
        |> put_status(400)
        |> render(ErrorView, "400.json", %{error: "Bad request"})
    end
  end
end
