defmodule Todo.Repo.Migrations.AddUniqueIndexToUsers do
  use Ecto.Migration

  def change do
    create index(:users, [:encrypted_username_password], name: :users_encrypted_username_password_index, unique: true)
  end
end
