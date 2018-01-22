defmodule Todo.Repo.Migrations.AddIndexToLists do
  use Ecto.Migration

  def change do
    create index(:lists, [:id, :user_id], unique: true)
  end
end
