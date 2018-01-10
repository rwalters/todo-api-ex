defmodule Todo.AuthenticationController do
  import Plug.Conn
  require Exredis.Api

  use Todo.Web, :controller
  use Timex

  def authenticate(conn, _params) do
    user = Todo.UserSession.current_user(conn)
    render(conn, "authenticate.json", %{token: generate_and_cache_token(user.id), expires_at: expires_at()})
  end

  defp expires_at do
    Timex.now
    |> Timex.add(Duration.from_minutes(20))
    |> Ecto.DateTime.cast
    |> case do
      {:ok, date} -> Ecto.DateTime.to_string(date)
      _ -> nil
    end
  end

  defp generate_and_cache_token(user_id) do
    token = Ecto.UUID.generate()

    {:ok, client} = Exredis.start_link
    client |> Exredis.Api.setex("token.#{token}", 1200, user_id)

    token
  end
end
