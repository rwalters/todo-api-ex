defmodule Todo.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :list_id, references(:lists, type: :uuid, on_delete: :delete_all)
      add :finished_at, :utc_datetime

      timestamps()
    end
  end
end
