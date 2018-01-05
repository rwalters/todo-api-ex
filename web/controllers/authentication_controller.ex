defmodule Todo.AuthenticationController do
  import Plug.Conn

  use Todo.Web, :controller
  use Timex

  def authenticate(conn, _params) do
    render(conn, "authenticate.json", %{token: token(), expires_at: expires_at()})
  end

  defp token do
    Ecto.UUID.generate()
    "abcdef"
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
end
