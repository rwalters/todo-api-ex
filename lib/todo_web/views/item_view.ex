defmodule Todo.ItemView do
  use TodoWeb, :view

  def render("show.json", %{item: item}) do
    render_one(item, Todo.ItemView, "item.json")
  end

  def render("item.json", %{item: item}) do
    %{
      id: item.id,
      src: "http://localhost:4000/lists/#{item.list_id}/items/#{item.id}",
      name: item.name,
      finished_at: item.finished_at
    }
  end
end
