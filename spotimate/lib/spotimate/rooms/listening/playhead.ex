defmodule Spotimate.Rooms.Listening.Playhead do
  use Agent
  alias Spotimate.Rooms.Listening.Playhead
  alias Spotimate.Rooms.Listening.Queue
  alias Spotimate.Utils.Time

  defstruct song: %Spotify.Track{},
            position_ms: 0,
            start_time: 0,
            time_calculated: 0,
            queue_pid: nil

  def start_link(_opts) do
    Agent.start_link(fn -> %Playhead{} end)
  end

  def attach_queue(pid, queue_pid) do
    Agent.update(pid, &Map.put(&1, "queue_pid", queue_pid))
  end

  # Entry point to playing
  def init(pid) do
    queue_pid = Agent.get(pid, &Map.get(&1, "queue_pid"))
    play(pid, queue_pid)
  end

  # Recursive play loop
  def play(pid, queue_pid) do
    song = Queue.pop(queue_pid)
    %Spotify.Track{
      duration_ms: duration_ms,
    } = song
    IO.puts "duration MS"
    IO.inspect duration_ms
    
    # Start track
    start_track(pid, :os.system_time(:millisecond), song)

    # Spawn timer process for track duration
    spawn fn ->
      Time.delayed_action(duration_ms, fn -> play(pid, queue_pid) end)
    end
  end

  defp start_track(pid, start_time, song) do
    Agent.update(pid, &Map.put(&1, "start_time", start_time))
    Agent.update(pid, &Map.put(&1, "song", song))
  end

  def fetch(pid) do
    song       = Agent.get(pid, &Map.get(&1, "song"))
    start_time = Agent.get(pid, &Map.get(&1, "start_time"))
    queue_pid      = Agent.get(pid, &Map.get(&1, "queue_pid"))
    now = :os.system_time(:millisecond)
    position_ms = now - start_time
    if position_ms < song.duration_ms do
      %Playhead{
        song:            song,
        position_ms:     position_ms,
        start_time:      start_time,
        time_calculated: now,
      }
    else
     {:error, "Expired Playhead"}
    end
  end

end