defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.{Repo, List}

  import Todo.ErrorHelpers

  def index(conn, _params) do
    user = Todo.UserSession.current_user(conn)
    render(conn, "index.json", lists: user.lists)
  end

  def show(conn, %{"id" => uuid}) do
    with user             <- Todo.UserSession.current_user(conn),
         {:ok, uuid}      <- Ecto.UUID.cast(uuid),
         list = %List{}   <- find_list(user, uuid) |> Repo.preload(:items) do

      render(conn, "show.json", list: list)
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn, "List not found")
    end
  end

  def create(conn, %{"list" => %{"name" => name}}) do
    with user           <- Todo.UserSession.current_user(conn),
         changeset      <- Ecto.build_assoc(user, :lists, name: name),
         {:ok, list}    <- Repo.insert(changeset) do

      conn
      |> put_status(201)
      |> render("create.json", list: list)
    else
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def update(conn, %{"id" => uuid, "list" => params}) do
    with user               <- Todo.UserSession.current_user(conn),
         {:ok, uuid}        <- Ecto.UUID.cast(uuid),
         list = %List{}     <- find_list(user, uuid) |> Repo.preload(:user),
         changeset          <- List.changeset(list, params),
         {:ok, updated}     <- Repo.update(changeset) do

      conn
      |> put_status(201)
      |> render("update.json", list: updated)
    else
      nil -> not_found(conn, "List not found")
      :error -> malformed_request(conn)
      {:error, %{errors: errors}} -> errors(conn, errors)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with user               <- Todo.UserSession.current_user(conn),
         {:ok, uuid}        <- Ecto.UUID.cast(uuid),
         list = %List{}     <- find_list(user, uuid),
         {:ok, _list}       <- Repo.delete(list) do

      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    else
      :error -> malformed_request(conn)
      nil -> not_found(conn, "List not found")
    end
  end

  defp find_list(user, id) do
    assoc(user, :lists)
    |> Repo.get(id)
  end
end
