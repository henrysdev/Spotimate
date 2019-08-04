defmodule SpotimateWeb.AuthController do
  use SpotimateWeb, :controller
  alias Spotimate.Accounts.User
  alias Spotimate.Accounts.Auth

  def login(conn, _params) do
    redirect conn, external: Spotify.Authorization.url
  end

  def callback(conn, params) do
    case Spotify.Authentication.authenticate(conn, params) do
      {:ok, conn} ->
        case Auth.login_or_register(conn) do
          %User{
            id:       id,
            username: username,
            email:    email,
          } -> conn
                |> put_session(:user_id, id)
                |> put_session(:username, username)
                |> put_session(:email, email)
                |> redirect(to: "/user/home")
          _ -> redirect conn, to: "/error"
        end
      {:error, reason, conn} -> redirect conn, to: "/error"
    end
  end

end
