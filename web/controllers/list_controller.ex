defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.{Repo, List}

  def index(conn, _params) do
    lists = Repo.all(List)
    render(conn, "index.json", lists: lists)
  end
end
