defmodule Todo.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:item, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string
      add :list_id, :uuid
    end
  end
end
