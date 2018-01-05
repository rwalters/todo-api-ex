defmodule Todo.AuthenticationView do
  use Todo.Web, :view

  def render("authenticate.json", %{token: token}) do
    %{
      token: token,
      expires_at: "2017-12-25 12:20:00 -0600"
    }
  end
end
