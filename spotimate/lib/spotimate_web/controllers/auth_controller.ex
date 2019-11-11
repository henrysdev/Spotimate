defmodule SpotimateWeb.AuthController do
  use SpotimateWeb, :controller

  alias Spotimate.{
    Accounts.DataModel.User,
    Accounts.Auth,
    Utils.Time
  }

  def login(conn, _params) do
    redirect(conn, external: Spotify.Authorization.url())
  end

  def callback(conn, params) do
    case Spotify.Authentication.authenticate(conn, params) do
      {:ok, conn} ->
        case Auth.login_or_register(conn) do
          %User{
            id: id,
            username: username,
            email: email
          } ->
            conn
            |> put_session(:user_id, id)
            |> put_session(:username, username)
            |> put_session(:email, email)
            |> put_session(:token_expiry, Time.future_utc_millis(60 * 20 * 1000))
            |> redirect(to: "/home")

          _error ->
            redirect(conn, to: "/error")
        end

      _error ->
        redirect(conn, to: "/error")
    end
  end
end
