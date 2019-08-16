defmodule SpotimateWeb.RoomController do
  use SpotimateWeb, :controller

  alias Spotimate.{
    Listening.Room,
    Listening.DataModel,
    Listening.RecGenerators,
    Spotify.Player,
    Utils,
  }

  def new_room(conn, %{"name" => name, "seed_uri" => seed_uri}) do
    creator_id = get_session(conn, :user_id)
    
    # Create and persist new room
    %DataModel.Room{
      id:       id,
      seed_uri: seed_uri,
    } = Room.new_room(name, creator_id, seed_uri)

    # Spawn process for newly created room
    Room.spawn_room(conn, id, :default)
  end

  def listen(conn, %{"device_id" => device_id}) do
    # Persist device id with session
    conn = put_session(conn, :device_id, device_id)

    # Fetch applicable session data
    acc_tok = Spotify.Cookies.get_access_token(conn)
    %{
      :curr_room => room_id,
      :user_id   => user_id,
      :device_id => device_id,
    } = Utils.Session.fetch_multiple(conn, [:curr_room, :user_id, :device_id])

    # Get playhead
    playhead = Room.obtain_playhead(conn, room_id, user_id)
    
    # Start playing track
    Player.play_track(playhead, acc_tok, device_id)

    # Return next deadline
    json(conn, Poison.encode!%{
      "deadline_utc" => playhead.deadline_utc,
    })
  end

end
