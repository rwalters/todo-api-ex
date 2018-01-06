defmodule Todo.Item do
  use Todo.Web, :model

  @primary_key {:id, :binary_id, [autogenerate: true]}
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
    |> cast(params, [:name, :id])
    |> validate_required([:name])
  end
end
