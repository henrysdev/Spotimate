defmodule Spotimate.Accounts.Auth do
  alias Spotimate.Accounts.UsersDAO
  alias Spotimate.Accounts.User

  def login_or_register(conn) do
    {:ok, %Spotify.Profile{
      id:    username,
      email: email,
    }} = Spotify.Profile.me(conn)
    if UsersDAO.exists?(:username, username) do
      UsersDAO.fetch_by_attr(:username, username)
    else
      UsersDAO.insert(%User{
        username: username,
        email:    email,
      })
    end
  end

end