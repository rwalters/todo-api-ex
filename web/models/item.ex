defmodule Todo.Item do
  use Todo.Web, :model

  @primary_key {:uuid, :binary_id, [autogenerate: true]}

  schema "item" do
    field :name, :string
    field :finished_at, :utc_datetime
    belongs_to :list, Todo.List, references: :uuid
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
