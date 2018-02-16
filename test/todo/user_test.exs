defmodule Todo.UserTest do
  use Todo.DataCase, async: true

  test "changeset with valid attributes" do
    changeset = Todo.User.changeset(%Todo.User{}, %{username: "something", password: "password"})
    assert changeset.valid?
  end

  test "changeset with duplicate username and password" do
    changeset = Todo.User.changeset(%Todo.User{}, %{username: "something", password: "password"})
    Todo.Repo.insert(changeset)

    changeset = Todo.User.changeset(%Todo.User{}, %{username: "something", password: "password"})
    assert !changeset.valid?
  end
end
