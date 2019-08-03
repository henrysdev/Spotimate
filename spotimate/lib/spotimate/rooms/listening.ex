defmodule Spotimate.Rooms.Listening do
  alias Spotimate.Rooms.Room
  alias Spotimate.Rooms.RoomsDAO
  alias Spotimate.Rooms.Listening.Playhead
  alias Spotimate.Rooms.Listening.Queue
  alias Spotimate.Spotify

  def new_room(name, creator_id, acc_tok, seed_uri) do
    # Store room in DB
    {:ok, room} = RoomsDAO.insert(%Room{
      name:       name,
      creator_id: creator_id,
      seed_uri:   seed_uri,
    })

    # Spawn and register queue
    contents = build_queue_DEBUG(acc_tok, room.seed_uri)
    {:ok, q_id} = Queue.start_link([], contents)
    queue = registered_queue(room.id)
    Process.register(q_id, queue)

    # Spawn and register playhead
    {:ok, ph_pid} = Playhead.start_link([])
    playhead = registered_playhead(room.id)
    Process.register(ph_pid, playhead)

    # Start Playthrough
    # TODO link Queue + Playhead to be synchronized
    # TODO remove/gut duplicate logic in restart_playhead
    spawn fn -> Queue.playthrough(queue, playhead) end
    Process.sleep(1000)
    Playhead.fetch(playhead)
  end

  def obtain_playhead(room_id, user_id, acc_tok) do
    playhead = registered_playhead(room_id)
    plh_in_db? = RoomsDAO.exists?(:id, room_id)
    plh_in_mem? = case Process.whereis(playhead) do
      nil      -> false
      real_pid -> Process.alive?(real_pid)
    end
    case {plh_in_db?, plh_in_mem?} do
      {false, _}    -> {:error, "Room does not exist"}
      {true, true}  -> Playhead.fetch(playhead)
      {true, false} -> restart_playhead(room_id, acc_tok)
    end
  end

  def restart_playhead(room_id, acc_tok) do
    # Fetch room from DB
    room = RoomsDAO.fetch_by_attr(:id, room_id)

    # Spawn and register queue
    contents = build_queue_DEBUG(acc_tok, room.seed_uri)
    {:ok, q_id} = Queue.start_link([], contents)
    queue = registered_queue(room_id)
    Process.register(q_id, queue)

    # Spawn and register playhead process
    {:ok, ph_pid} = Playhead.start_link([])
    playhead = registered_playhead(room.id)
    Process.register(ph_pid, playhead)

    # Start Playthrough
    spawn fn -> Queue.playthrough(queue, playhead) end
    Process.sleep(1000)
    Playhead.fetch(playhead)
  end

  defp build_queue_DEBUG(acc_tok, seed_uri) do
    # TODO actually generate recs to build queue
    # Spotify.API.recommendations(acc_tok, [seed_uri])
    song = %Spotify.Song{
      uri: seed_uri,
      name: "First Song",
      artists: ["foo", "bar"],
      duration_ms: 60000,
    }
    generate_recs = &[&1, &1, &1]
    generate_recs.(song)
  end

  def registered_playhead(room_id) do
    String.to_atom("playhead_#{room_id}")
  end

  def registered_queue(room_id) do
    String.to_atom("queue_#{room_id}")
  end

end