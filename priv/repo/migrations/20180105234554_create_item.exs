defmodule Todo.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:item, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :list_id, references(:list, type: :uuid, on_delete: :delete_all)
    end
  end
end
