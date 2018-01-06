defmodule Todo.Repo.Migrations.CreateList do
  use Ecto.Migration

  def change do
    create table(:list, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :finished_at, :utc_datetime
    end
  end
end
