defmodule Todo.Router do
  use Todo.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Todo do
    pipe_through :api
    get "/lists", ListController, :index
    get "/lists/:id", ListController, :show
    post "/lists", ListController, :create
    # patch "/lists/:id", ListController, :update
  end
end
