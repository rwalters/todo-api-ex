defmodule Todo.Repo.Migrations.AddIndexToLists do
  use Ecto.Migration

  def change do
    create index(:lists, [:user_id, :name], name: :lists_user_id_name_index, unique: true)
  end
end
