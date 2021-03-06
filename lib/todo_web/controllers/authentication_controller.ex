defmodule TodoWeb.AuthenticationController do
  import Plug.Conn

  alias Todo.Cache

  use TodoWeb, :controller
  use Timex

  def authenticate(conn, _params) do
    with user <- Todo.UserSession.current_user(conn) do
      render(conn, "authenticate.json", %{
        token: generate_and_cache_token(user.id),
        expires_at: expires_at()
      })
    end
  end

  defp expires_at do
    Timex.now()
    |> Timex.add(Duration.from_minutes(20))
    |> Ecto.DateTime.cast()
    |> case do
      {:ok, date} -> Ecto.DateTime.to_string(date)
      _ -> nil
    end
  end

  defp generate_and_cache_token(user_id) do
    with token <- Ecto.UUID.generate() do
      Cache.start_link()
      Cache.setex("token.#{token}", 1200, user_id)

      token
    end
  end
end
