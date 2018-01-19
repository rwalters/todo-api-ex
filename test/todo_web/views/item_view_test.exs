defmodule TodoWeb.ItemViewTest do
  use TodoWeb.ConnCase, async: true

  import Phoenix.View

  setup do
    item = %Todo.Item{name: "buy milk", list_id: "123-abc", id: "987-zyx"}
    {:ok, item: item}
  end

  test "renders single item", state do
    assert render(TodoWeb.ItemView, "show.json", item: state.item) == %{
             finished_at: nil,
             id: "987-zyx",
             name: "buy milk",
             src: "http://localhost:4000/lists/123-abc/items/987-zyx"
           }
  end
end
