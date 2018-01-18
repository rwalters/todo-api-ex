defmodule Todo.AuthenticationView do
  use TodoWeb, :view

  def render("authenticate.json", %{token: token, expires_at: expires_at}) do
    %{
      token: token,
      expires_at: expires_at
    }
  end
end
