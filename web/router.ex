defmodule Todo.Router do
  use Todo.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :basic_auth do
    plug BasicAuth, username: "username", password: "password"
  end

  pipeline :token_auth do
    plug TokenAuth
  end

  scope "/api", Todo do
    pipe_through [:api, :basic_auth]

    post "/authenticate", AuthenticationController, :authenticate
  end

  scope "/api", Todo do
    pipe_through [:api, :token_auth]
    get "/lists", ListController, :index
    get "/lists/:id", ListController, :show
    post "/lists", ListController, :create
    delete "/lists/:id", ListController, :delete
    patch "/lists/:id", ListController, :update
  end
end
