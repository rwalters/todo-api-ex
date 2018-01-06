defmodule Todo.Item do
  use Todo.Web, :schema

  schema "items" do
    field :name, :string
    field :finished_at, :utc_datetime
    belongs_to :list, Todo.List

    timestamps()
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