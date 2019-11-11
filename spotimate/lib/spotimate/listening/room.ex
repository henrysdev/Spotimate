defmodule Spotimate.Listening.Room do
  alias Spotimate.{
    Listening.DataModel.RoomsDAO,
    Listening.DataModel.Room,
    Listening.Room.Playhead,
    Listening.Room.Queue,
    Listening.RecGenerators,
    Utils
  }

  def new_room(name, creator_id, seed_uri) do
    # Insert room into DB
    {:ok, room} =
      RoomsDAO.insert(%Room{
        name: name,
        creator_id: creator_id,
        seed_uri: seed_uri
      })

    room
  end

  def spawn_room(conn, room_id) do
    # Fetch room from DB and start it up
    %Room{
      id: id,
      seed_uri: seed_uri
    } = RoomsDAO.fetch_by_id(room_id)

    # Spawn and register playhead (that will pull from queue)
    {:ok, ph_pid} = Playhead.start_link([])
    playhead = registered_playhead(id)
    Process.register(ph_pid, playhead)

    # Determine what function to use to generate tracks for the queue
    gen_tracks = RecGenerators.spotify_recs(conn, seed_uri, 100)

    # Spawn queue
    {:ok, q_pid} = Queue.start_link([], gen_tracks.())

    # Attach queue
    Playhead.attach_queue(playhead, q_pid)

    # Start Playthrough
    Playhead.play_next(playhead, q_pid)

    # Allow time for async setup before returning playhead
    # TODO improve this...
    Process.sleep(100)
    Playhead.fetch(playhead)
  end

  def obtain_playhead(conn, room_id, user_id) do
    playhead = registered_playhead(room_id)
    plh_in_db? = RoomsDAO.exists?(:id, room_id)

    plh_in_mem? =
      case Process.whereis(playhead) do
        nil -> false
        real_pid -> Process.alive?(real_pid)
      end

    case {plh_in_db?, plh_in_mem?} do
      {false, _} -> {:error, "Room does not exist"}
      {true, true} -> Playhead.fetch(playhead)
      {true, false} -> spawn_room(conn, room_id)
    end
  end

  def registered_playhead(room_id) do
    String.to_atom("playhead_#{room_id}")
  end
end
