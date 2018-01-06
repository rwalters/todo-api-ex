defmodule Todo.List do
  use Todo.Web, :schema
  alias Todo.List

  schema "lists" do
    field :name, :string
    has_many :items, Todo.Item

    field :username, :string, virtual: true
    field :password, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(%List{} = user, params \\ %{}) do
    user
    |> cast(params, [:name, :id])
    |> validate_required([:name])
  end
end
