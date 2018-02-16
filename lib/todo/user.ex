defmodule Todo.User do
  use TodoWeb, :schema

  alias Todo.User

  schema "users" do
    field(:encrypted_username_password, :string)
    field(:username, :string, virtual: true)
    field(:password, :string, virtual: true)
    has_many(:lists, Todo.List)

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:password, min: 8)
    |> encrypt_username_and_password()
    |> unique_constraint(
      :encrypted_username_password,
      name: :users_encrypted_username_password_index
    )
    |> unsafe_validate_unique(
      [:encrypted_username_password],
      Todo.Repo,
      message: "has already been taken"
    )
  end

  def encrypt_username_and_password(
        %Ecto.Changeset{valid?: true, changes: %{username: username, password: password}} =
          changeset
      ) do
    put_change(
      changeset,
      :encrypted_username_password,
      encode(username, password)
    )
  end

  def encode(username, password), do: Base.encode64(username <> ":" <> password)
end
