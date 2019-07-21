defmodule SpotimateWeb.OAuth2Controller do
  use SpotimateWeb, :controller

  def login(conn, _params) do
    redirect(conn, external: Spotimate.Auth.spotify_authorize_uri)
  end

  def callback(conn, _params) do
    %{ "access_token"  => acc_tok,
       "refresh_token" => ref_tok,
    } = conn.query_string
    |> URI.decode_query()
    |> Spotimate.Auth.get_authentication_response()
    
    # Spotimate.Cache.put(:cache, "access_token", acc_tok)
    # Spotimate.Cache.put(:cache, "refresh_token", ref_tok)

    conn = put_session(conn, :access_token, acc_tok)

    # Once tokens have been cached, redirect to home page
    redirect(conn, to: "/home")
  end

end
