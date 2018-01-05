defmodule Todo.Router do
  use Todo.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Todo do
    pipe_through :api
    get "/", ListsController, :index
  end
end
