defmodule Todo.List do
  use TodoWeb, :schema
  alias Todo.List

  schema "lists" do
    field(:name, :string)
    has_many(:items, Todo.Item)

    field(:username, :string, virtual: true)
    field(:password, :string, virtual: true)

    belongs_to(:user, Todo.User)

    timestamps()
  end

  def create(user, name: name) do
    Ecto.build_assoc(user, :lists)
    |> List.changeset(%{name: name})
    |> Todo.Repo.insert()
  end

  def update(list, params) do
    List.changeset(list, params)
    |> Todo.Repo.update()
  end

  @doc """
  Builds a changeset based on the `struct` and `attrs`.
  """
  def changeset(%List{} = list, attrs \\ %{}) do
    list
    |> cast(attrs, [:name, :id, :user_id])
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:name, name: :lists_user_id_name_index)
    |> unsafe_validate_unique([:name, :user_id], Todo.Repo, message: "has already been taken")
  end
end
