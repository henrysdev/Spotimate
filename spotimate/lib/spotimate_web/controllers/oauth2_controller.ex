defmodule SpotimateWeb.OAuth2Controller do
  use SpotimateWeb, :controller

  def login(conn, _params) do
    redirect(conn, external: Spotimate.Accounts.Auth.spotify_authorize_uri)
  end

  def callback(conn, _params) do
    %{ "access_token"  => acc_tok,
       "refresh_token" => ref_tok,
    } = conn.query_string
    |> URI.decode_query()
    |> Spotimate.Accounts.Auth.get_authentication_response()

    case Spotimate.Accounts.Auth.login_or_register(acc_tok) do
      %Spotimate.Accounts.User{
        id:       id,
        username: username,
        email:    email,
      } -> conn
        |> put_session(:access_token, acc_tok)
        |> put_session(:refresh_token, ref_tok)
        |> put_session(:user_id, id)
        |> put_session(:username, username)
        |> put_session(:email, email)
        |> redirect(to: "/user/home")
      resp -> send_resp(conn, 500, "Unable to Login")
    end
  end

end
