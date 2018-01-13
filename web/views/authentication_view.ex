defmodule Todo.AuthenticationView do
  use Todo.Web, :view

  def render("authenticate.json", %{token: token, expires_at: expires_at}) do
    %{
      token: token,
      expires_at: expires_at
    }
  end
end
