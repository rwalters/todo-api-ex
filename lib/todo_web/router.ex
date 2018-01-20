defmodule TodoWeb.Router do
  use TodoWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  pipeline :basic_auth do
    plug(BasicAuth)
  end

  pipeline :token_auth do
    plug(TokenAuth)
  end

  # Other scopes may use custom stacks.

  scope "/api", TodoWeb do
    pipe_through([:api, :basic_auth])

    post("/authenticate", AuthenticationController, :authenticate)
  end

  scope "/api", TodoWeb do
    pipe_through([:api, :token_auth])

    get("/lists", ListController, :index)
    get("/lists/:id", ListController, :show)
    post("/lists", ListController, :create)
    delete("/lists/:id", ListController, :delete)
    patch("/lists/:id", ListController, :update)

    post("/lists/:list_id/items", ItemController, :create)
    put("/lists/:list_id/items/:id/finish", ItemController, :finish)
    delete("/lists/:list_id/items/:id", ItemController, :delete)
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :todo, swagger_file: "swagger.json", disable_validator: true
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Todoable",
        host: "https://intense-hamlet-87296.herokuapp.com/"
      }
    }
  end
end
