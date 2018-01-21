defmodule TodoWeb.ItemView do
  use TodoWeb, :view

  def render("show.json", %{item: item}) do
    render_one(item, TodoWeb.ItemView, "item.json")
  end

  def render("finished.json", %{item: item}) do
    "#{item.name} finished"
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
