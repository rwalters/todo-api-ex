defmodule Todo.Repo.Migrations.AddUserIdToList do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
    end
  end
end
