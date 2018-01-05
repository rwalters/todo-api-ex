defmodule Todo.Router do
  use Todo.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug BasicAuth, username: "username", password: "password"
  end

  scope "/api", Todo do
    pipe_through :api
    get "/lists", ListController, :index
    get "/lists/:id", ListController, :show
    post "/lists", ListController, :create
    delete "/lists/:id", ListController, :delete
    # patch "/lists/:id", ListController, :update

    post "/authenticate", AuthenticationController, :authenticate
  end
end
