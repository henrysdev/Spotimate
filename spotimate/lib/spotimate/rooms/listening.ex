defmodule Spotimate.Rooms.Listening do
  alias Spotimate.{
    Rooms.Room,
    Rooms.RoomsDAO,
    Rooms.Listening.Playhead,
    Rooms.Listening.Queue,
    Utils,
  }

  # TODO Move somewhere else? Rename?
  def new_room(conn, name, creator_id, seed_uri) do
    # Store room in DB
    {:ok, room} = RoomsDAO.insert(%Room{
      name:       name,
      creator_id: creator_id,
      seed_uri:   seed_uri,
    })
    start_playhead(conn, room)
  end

  def start_playhead(conn, room) do
    # Spawn and register playhead (that will pull from queue)
    {:ok, ph_pid} = Playhead.start_link([])
    playhead = registered_playhead(room.id)
    Process.register(ph_pid, playhead)

    # TODO FIX FIX FIX Build queue
    {:ok, r} = Spotify.Recommendation.get_recommendations(conn,
      seed_tracks: Utils.String.extract_uri_id(room.seed_uri), limit: 100)
    contents = r.tracks
    {:ok, q_pid} = Queue.start_link([], contents)

    # Attach queue
    Playhead.attach_queue(playhead, q_pid)

    # Start Playthrough
    Playhead.init(playhead)

    # Allow time for async setup before returning playhead
    # TODO improve this...
    Process.sleep(500)
    Playhead.fetch(playhead)
  end

  def restart_playhead(conn, room_id) do
    # Fetch room from DB
    room = RoomsDAO.fetch_by_id(room_id)
    start_playhead(conn, room)
  end

  def obtain_playhead(conn, room_id, user_id) do
    playhead = registered_playhead(room_id)
    plh_in_db? = RoomsDAO.exists?(:id, room_id)
    plh_in_mem? = case Process.whereis(playhead) do
      nil      -> false
      real_pid -> Process.alive?(real_pid)
    end

    case {plh_in_db?, plh_in_mem?} do
      {false, _}    -> {:error, "Room does not exist"}
      {true, true}  -> Playhead.fetch(playhead)
      {true, false} -> restart_playhead(conn, room_id)
    end
  end

  def registered_playhead(room_id) do
    String.to_atom("playhead_#{room_id}")
  end

end