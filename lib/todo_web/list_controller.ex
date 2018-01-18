defmodule Todo.ListController do
  use TodoWeb, :controller

  alias Todo.{Repo}

  def index(conn, _params) do
    render(conn, "index.json", lists: [])
  end
end
