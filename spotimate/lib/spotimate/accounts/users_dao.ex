defmodule Spotimate.Accounts.UsersDAO do
  alias Spotimate.Repo
  alias Spotimate.Accounts.User
  import Ecto.Query

  def exists?(:username, val) do
    Repo.exists?(from u in User, where: ilike(u.username, ^val))
  end
  def exists?(:email, val) do
    Repo.exists?(from u in User, where: ilike(u.email, ^val))
  end
  def exists?(:id, val) do
    Repo.exists?(from u in User, where: u.id == ^val)
  end

  def insert(%User{} = user) do
    {:ok, user_record} = Repo.insert(user)
  end

  def fetch_by_attr(:username, val), do: Repo.get_by(User, username: val)
  def fetch_by_attr(:email, val), do: Repo.get_by(User, email: val)
  def fetch_by_attr(:id, val), do: Repo.get_by(User, id: val)

end