defmodule Todo.ListController do
  use TodoWeb, :controller

  alias Todo.{Repo}

  def index(conn, _params) do
    lists = Todo.Repo.all(Todo.List)
    render(conn, "index.json", lists: lists)
  end
end
