defmodule Todo.Router do
  use Todo.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :basic_auth do
    plug BasicAuth
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

    post "/lists/:list_id/items", ItemController, :create
    put "/lists/:list_id/items/:id/finish", ItemController, :finish
    delete "/lists/:list_id/items/:id", ItemController, :delete
  end
end
