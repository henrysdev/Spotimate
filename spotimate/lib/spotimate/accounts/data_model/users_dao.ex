defmodule Spotimate.Accounts.DataModel.UsersDAO do
  import Ecto.Query

  alias Spotimate.{
    Repo,
    Accounts.DataModel.User,
  }

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

  def fetch_by_username(username), do: Repo.get_by(User, username: username)
  def fetch_by_id(id), do: Repo.get_by(User, id: id)

end