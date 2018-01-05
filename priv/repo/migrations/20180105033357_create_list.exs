defmodule Todo.Repo.Migrations.CreateList do
  use Ecto.Migration

  def change do
    create table(:list, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string
    end
  end
end
