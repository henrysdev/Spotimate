defmodule Spotimate.Accounts.Auth do
  alias Spotimate.Accounts.DataModel.{
    UsersDAO,
    User
  }

  defp login(username) do
    UsersDAO.fetch_by_username(username)
  end

  defp register(username, email) do
    UsersDAO.insert(%User{
      username: username,
      email: email
    })
  end

  def login_or_register(conn) do
    {:ok,
     %Spotify.Profile{
       id: username,
       email: email
     }} = Spotify.Profile.me(conn)

    if UsersDAO.exists?(:username, username) do
      login(username)
    else
      register(username, email)
    end
  end
end
