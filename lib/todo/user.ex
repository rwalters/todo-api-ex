defmodule Todo.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Todo.User

  @primary_key {:id, :binary_id, [autogenerate: true]}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}

  schema "users" do
    field :encrypted_password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :encrypted_password])
    |> validate_required([:username, :encrypted_password])
  end
end
