defmodule Todo.User do
  use Todo.Web, :schema
  alias Todo.User

  schema "users" do
    field :encrypted_username_password, :string
    field :username, :string, virtual: true
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> registration_changeset
  end

  def registration_changeset(changeset) do
    changeset
    |> validate_required([:username, :password])
    |> validate_length(:password, min: 8)
    |> encrypt_username_and_password()
  end

  def encrypt_username_and_password(%Ecto.Changeset{valid?: true, changes: %{password: username, username: password}} = changeset) do
   put_change(
      changeset,
      :encrypted_username_and_password,
      encode(username, password)
    )
  end

  def encode(username, password), do: Base.encode64(username <> ":" <> password)
end
