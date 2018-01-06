defmodule Todo.List do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, [autogenerate: true]}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}

  schema "lists" do
    field :name, :string
    has_many :items, Todo.Item

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :id])
    |> validate_required([:name])
  end
end
