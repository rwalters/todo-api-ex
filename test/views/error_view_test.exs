defmodule Todo.ErrorViewTest do
  use Todo.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(Todo.ErrorView, "404.json", []) == %{errors: %{detail: "Resource not found"}}
  end

  test "render 500.json" do
    assert render(Todo.ErrorView, "500.json", []) == %{errors: %{detail: "Internal server error"}}
  end

  test "renders 422.json" do
    assert render(Todo.ErrorView, "422.json", []) == %{errors: %{detail: "Bad request"}}
  end

  test "render any other" do
    assert render(Todo.ErrorView, "505.json", []) == %{errors: %{detail: "Internal server error"}}
  end
end
