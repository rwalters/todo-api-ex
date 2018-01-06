defmodule Todo.Repo.Migrations.CreateList do
  use Ecto.Migration

  def change do
    create table(:lists, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
    end
  end
end
