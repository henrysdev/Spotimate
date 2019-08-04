defmodule SpotimateWeb.RoomController do
  use SpotimateWeb, :controller
  alias Spotimate.Rooms.Listening

  # TODO handle error cases

  def listen(conn, %{"device_id" => device_id}) do
    # Persist device id with session
    conn = put_session(conn, :device_id, device_id)
    room_id = get_session(conn, :curr_room)
    user_id = get_session(conn, :user_id)
    acc_tok = Map.get(conn.cookies, "spotify_access_token")
    device_id = get_session(conn, :device_id)

    # Determine if there is a live playhead process already spawned.
    playhead = Listening.obtain_playhead(conn, room_id, user_id)

    # Spawn subscriber listener process and return success
    Spotimate.Spotify.Player.play_track(acc_tok, device_id, playhead)

    json(conn, %{})
  end

  def new_room(conn, %{"name" => name, "seed_uri" => seed_uri}) do
    creator_id = get_session(conn, :user_id)
    Spotimate.Rooms.Listening.new_room(conn, name, creator_id, seed_uri)
  end

end
