defmodule TodoWeb.Router do
  use TodoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(:fetch_session)
  end

  pipeline :basic_auth do
    plug(BasicAuth)
  end

  pipeline :token_auth do
    plug(TokenAuth)
  end

  scope "/", TodoWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.

  scope "/api", Todo do
    pipe_through([:api, :basic_auth])

    post("/authenticate", AuthenticationController, :authenticate)
  end

  scope "/api", Todo do
    pipe_through([:api, :token_auth])
    get("/lists", ListController, :index)
    get("/lists", ListController, :index)
    get("/lists/:id", ListController, :show)
    post("/lists", ListController, :create)
    delete("/lists/:id", ListController, :delete)
    patch("/lists/:id", ListController, :update)

  end
end
