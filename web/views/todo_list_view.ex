defmodule Todo.ListView do
  use Todo.Web, :view

  def render("index.json", %{lists: lists}) do
    render_many(lists, Todo.ListView, "list.json")
  end

  def render("show.json", %{list: list}) do
    render_one(list, Todo.ListView, "list.json")
  end

  def render("list.json", %{list: list}) do
    %{
      uuid: list.uuid,
      name: list.name,
    }
  end
end
