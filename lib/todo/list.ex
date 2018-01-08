defmodule Todo.List do
  use Todo.Web, :schema
  alias Todo.List

  schema "lists" do
    field :name, :string
    has_many :items, Todo.Item

    field :username, :string, virtual: true
    field :password, :string, virtual: true

    belongs_to :user, Todo.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `attrs`.
  """
  def changeset(%List{} = list, attrs \\ %{}) do
    list
    |> cast(attrs, [:name, :id])
    |> validate_required([:name])
  end
end
