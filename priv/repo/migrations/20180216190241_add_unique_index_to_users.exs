defmodule Todo.Repo.Migrations.AddUniqueIndexToUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:encrypted_username_password])
  end
end
