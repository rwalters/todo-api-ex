defmodule Todo.User do
  use Todo.Web, :schema
  alias Todo.User

  schema "users" do
    field :encrypted_username_password, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:encrypted_username_password])
    |> validate_required([:encrypted_username_password])
  end

  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:password, min: 8)
    |> encrypt_username_and_password()
    |> changeset(attrs)
  end

  defp encrypt_username_and_password(%Ecto.Changeset{valid?: true, changes: %{password: username, username: password}} = changeset) do
   put_change(
      changeset,
      :encrypted_username_and_password,
      encode(username, password)
    )
  end

  defp encode(username, password), do: Base.encode64(username <> ":" <> password)
end
