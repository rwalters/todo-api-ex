defmodule Todo.ListController do
  use TodoWeb, :controller

  alias Todo.{Repo}

  def index(conn, _params) do
    user = Todo.UserSession.current_user(conn)
    render(conn, "index.json", lists: user.lists)
  end
end
