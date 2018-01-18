defmodule Todo.ListView do
  use TodoWeb, :view

  def render("index.json", %{lists: lists}) do
    %{lists: render_many(lists, Todo.ListView, "list.json")}
  end

  def render("list.json", %{list: list}) do
    %{
      id: "123",
      src: "url",
      name: "Shopping"
    }
  end
end
