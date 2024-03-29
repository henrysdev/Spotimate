defmodule SpotimateWeb.RoomController do
  use SpotimateWeb, :controller

  alias Spotimate.{
    Listening.Room,
    Listening.DataModel,
    Spotify.Player,
    Utils
  }

  def new_room(conn, %{"name" => name, "seed_uri" => seed_uri}) do
    creator_id = get_session(conn, :user_id)

    # Create and persist new room
    %DataModel.Room{
      id: id
    } = Room.new_room(name, creator_id, seed_uri)

    # Spawn process for newly created room
    Room.spawn_room(conn, id)
  end

  def listen(conn, %{"device_id" => device_id, "room_id" => room_id}) do
    # Persist device id with session
    conn = put_session(conn, :device_id, device_id)

    # Fetch applicable session data
    acc_tok = Spotify.Cookies.get_access_token(conn)

    device_id = get_session(conn, :device_id)

    # Get playhead
    playhead = Room.obtain_playhead(conn, room_id)

    # Start playing track
    Player.play_track(playhead, acc_tok, device_id)

    # Return next deadline
    json(
      conn,
      Poison.encode!(%{
        "deadline_utc" => playhead.deadline_utc
      })
    )
  end
end
