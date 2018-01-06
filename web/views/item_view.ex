defmodule Todo.ItemView do
  use Todo.Web, :view

  def render("show.json", %{item: item}) do
    render_one(item, Todo.ItemView, "item.json")
  end

  def render("item.json", %{item: item}) do
    %{
      id: item.uuid,
      src: "http://localhost:4000/lists/#{item.list}/items/#{item.uuid}",
      name: item.name,
      finished_at: item.finished_at,
    }
  end
end
