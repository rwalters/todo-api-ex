defmodule Todo.List do
  use Todo.Web, :schema

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
