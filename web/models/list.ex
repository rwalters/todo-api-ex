defmodule Todo.List do
  use Todo.Web, :model

  @primary_key {:uuid, :binary_id, [autogenerate: true]}

  schema "list" do
    field :name, :string
    has_many :items, Todo.Item, foreign_key: :list_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :uuid])
    |> validate_required([:name])
  end
end
