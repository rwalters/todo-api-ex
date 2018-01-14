defmodule Todo.ListView do
  use Todo.Web, :view

  def render("index.json", %{lists: lists}) do
    %{lists: render_many(lists, Todo.ListView, "list.json")}
  end

  def render("show.json", %{list: list}) do
    render_one(list, Todo.ListView, "list_with_items.json")
  end

  def render("create.json", %{list: list}) do
    render_one(list, Todo.ListView, "list.json")
  end

  def render("update.json", %{list: list}) do
    "#{list.name} updated"
  end

  def render("list.json", %{list: list}) do
    %{
      id: list.id,
      src: "http://localhost:4000/lists/#{list.id}",
      name: list.name
    }
  end

  def render("list_with_items.json", %{list: list}) do
    %{
      id: list.id,
      src: "http://localhost:4000/lists/#{list.id}",
      name: list.name,
      items: render_many(list.items, Todo.ItemView, "item.json"),
      user_id: list.user_id
    }
  end
end
