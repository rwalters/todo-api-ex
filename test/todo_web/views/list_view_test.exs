defmodule TodoWeb.ListViewTest do
  use TodoWeb.ConnCase, async: true

  import Phoenix.View

  setup do
    lists = [
      %Todo.List{name: "Shopping", id: "123-abc"},
      %Todo.List{name: "Groceries", id: "456-def"}
    ]

    list = %Todo.List{
      name: "Moving",
      id: "789-ghi",
      user_id: "abcdef-123456",
      items: [
        %Todo.Item{name: "boxes", id: "987-zyx"},
        %Todo.Item{name: "tape", id: "654-wvu"}
      ]
    }

    {:ok, lists: lists, list: list}
  end

  test "renders empty set of lists" do
    assert render(TodoWeb.ListView, "index.json", lists: []) == %{lists: []}
  end

  test "renders several lists", state do
    assert render(TodoWeb.ListView, "index.json", lists: state.lists) == %{
             lists: [
               %{id: "123-abc", name: "Shopping", src: "http://localhost:4000/lists/123-abc"},
               %{id: "456-def", name: "Groceries", src: "http://localhost:4000/lists/456-def"}
             ]
           }
  end

  test "renders single list with user_id and items", state do
    assert render(TodoWeb.ListView, "show.json", list: state.list) == %{
             id: "789-ghi",
             items: [
               %{
                 finished_at: nil,
                 id: "987-zyx",
                 name: "boxes",
                 src: "http://localhost:4000/lists//items/987-zyx"
               },
               %{
                 finished_at: nil,
                 id: "654-wvu",
                 name: "tape",
                 src: "http://localhost:4000/lists//items/654-wvu"
               }
             ],
             name: "Moving",
             src: "http://localhost:4000/lists/789-ghi",
             user_id: "abcdef-123456"
           }
  end

  test "renders a created list, no items", state do
    assert render(TodoWeb.ListView, "create.json", list: state.list) == %{
             id: "789-ghi",
             name: "Moving",
             src: "http://localhost:4000/lists/789-ghi"
           }
  end
end
