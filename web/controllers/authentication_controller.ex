defmodule Todo.AuthenticationController do
  use Todo.Web, :controller

  import Ecto

  def authenticate(conn, _params) do
    token = Ecto.UUID.generate()
    render(conn, "authenticate.json", %{token: token})
  end
end
