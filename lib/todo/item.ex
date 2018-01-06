defmodule Todo.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, [autogenerate: true]}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}

  schema "items" do
    field :name, :string
    field :finished_at, :utc_datetime
    belongs_to :list, Todo.List
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :id, :finished_at])
    |> validate_required([:name])
  end
end
