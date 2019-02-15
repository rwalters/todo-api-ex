defmodule TodoWeb.ErrorHelpers do
  alias TodoWeb.ErrorView

  def malformed_request(conn), do: malformed_request(conn, "Bad request")

  def malformed_request(conn, errors) do
    conn
    |> Plug.Conn.put_status(400)
    |> Phoenix.Controller.put_view(ErrorView)
    |> Phoenix.Controller.render("400.json", %{error: errors})
  end

  def not_found(conn), do: not_found(conn, "Resource not found")

  def not_found(conn, errors) do
    conn
    |> Plug.Conn.put_status(404)
    |> Phoenix.Controller.put_view(ErrorView)
    |> Phoenix.Controller.render("404.json", %{error: errors})
  end

  def errors(conn), do: errors(conn, "Bad request")

  def errors(conn, errors) do
    conn
    |> Plug.Conn.put_status(422)
    |> Phoenix.Controller.put_view(ErrorView)
    |> Phoenix.Controller.render("422.json", %{error: errors})
  end
end
