defmodule SpotimateWeb.RoomController do
  use SpotimateWeb, :controller
  alias Spotimate.Rooms.Listening

  # TODO handle error cases

  def listen(conn, %{"device_id" => device}) do
    # Persist device id with session
    conn = put_session(conn, :device_id, device)
    room_id = get_session(conn, :curr_room)
    user_id = get_session(conn, :user_id)
    acc_tok = get_session(conn, :acc_tok)

    # Determine if there is a live playhead process already spawned.
    playhead = Listening.obtain_playhead(room_id, user_id, acc_tok)

    playhead |> IO.inspect()

    # pid = Listening.registered_playhead(room_id)
    # exists_in_db?  = RoomsDAO.exists?(:id, room_id)
    # exists_in_mem? = Process.whereis(pid)

    # playhead = case {exists_in_db?, exists_in_mem?} do
    #   {true, true} -> Listening.get_playhead(pid)
    #   {true, nil}  -> Listening.restart_room(pid)
    #   _            -> {:error, "room does not exist"}
    # end

    json(conn, %{})
  end

  def new_room(conn, %{"name" => name, "seed_uri" => seed_uri}) do
    creator_id = get_session(conn, :user_id)
    acc_tok    = get_session(conn, :acc_tok)
    Spotimate.Rooms.Listening.new_room(name, creator_id, acc_tok, seed_uri)
  end

  # TODO: deprecate (only used for testing)
  # def pause(conn, _params) do
  #   acc_tok = get_session(conn, :access_token)
  #   Spotimate.Spotify.API.pause_song(acc_tok)
  #   json(conn, %{})
  # end

  def play(conn, params) do
    acc_tok = get_session(conn, :access_token)
    device_id = get_session(conn, :device_id)
    
    # fetch from room
    context_uri = "spotify:album:5ht7ItJgpBH7W6vJ5BqpPr"
    position_ms = 0
    
    Spotimate.Spotify.API.play_song(acc_tok, context_uri, position_ms, device_id)
    json(conn, %{})
  end

end
