defmodule SpotimateWeb.PlaybackController do
  use SpotimateWeb, :controller

  # TODO handle error cases

  def browser_device(conn, %{"device_id" => device}) do
    put_session(conn, :device_id, device)
    user_id = get_session(conn, :user_id)
    json(conn, %{})
  end

  def pause(conn, _params) do
    acc_tok = get_session(conn, :access_token)
    Spotimate.Spotify.API.pause_song(acc_tok)
    json(conn, %{})
  end

  def play(conn, params) do
    acc_tok     = get_session(conn, :access_token)
    context_uri = "spotify:album:5ht7ItJgpBH7W6vJ5BqpPr"
    Spotimate.Spotify.API.play_song(acc_tok, context_uri, "4b8beb6da1d7b18983ca5a6fd81d220a317e8aba")
    json(conn, %{})
  end

end
