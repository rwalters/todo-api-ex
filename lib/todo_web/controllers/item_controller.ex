defmodule TodoWeb.ItemController do
  use TodoWeb, :controller

  alias Todo.{Repo, List, Item}

  import TodoWeb.ErrorHelpers

  def create(conn, %{"list_id" => list_id, "item" => %{"name" => name}}) do
    with list = %List{} <- Repo.get(List, list_id),
         changeset <- Ecto.build_assoc(list, :items, name: name),
         {:ok, item} <- Repo.insert(changeset) do
      conn
      |> put_status(201)
      |> render("show.json", item: item)
    else
      nil -> not_found(conn, "Item not found")
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def finish(conn, %{"list_id" => list_id, "id" => id}) do
    with {:ok, list_id} <- Ecto.UUID.cast(list_id),
         {:ok, id} <- Ecto.UUID.cast(id),
         list = %List{} <- Repo.get(List, list_id),
         item = %Item{} <- find_item(list, id) |> Repo.preload(:list),
         changeset <- Item.changeset(item, %{finished_at: DateTime.utc_now()}),
         {:ok, updated} <- Repo.update(changeset) do
      conn
      |> put_status(201)
      |> render("finished.json", item: updated)
    else
      nil -> not_found(conn, "Item not found")
      :error -> malformed_request(conn)
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def delete(conn, %{"list_id" => list_id, "id" => id}) do
    with {:ok, list_id} <- Ecto.UUID.cast(list_id),
         {:ok, id} <- Ecto.UUID.cast(id),
         list = %List{} <- Repo.get(List, list_id),
         item = %Item{} <- find_item(list, id),
         {:ok, _item} <- Repo.delete(item) do
      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    else
      nil -> not_found(conn, "Item not found")
      :error -> malformed_request(conn)
    end
  end

  defp find_item(list, id) do
    Ecto.assoc(list, :items)
    |> Repo.get(id)
  end
end
