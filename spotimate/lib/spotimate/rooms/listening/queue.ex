defmodule Spotimate.Rooms.Listening.Queue do
  use Agent
  alias Spotimate.Rooms.Listening.Playhead
  alias Spotimate.Rooms.Listening.Queue
  alias Spotimate.Spotify

  def start_link(_opts, init_contents \\ []) do
    Agent.start_link(fn -> init_contents end)
  end

  def push(pid, %Spotify.Song{} = song) do
    Agent.update(pid, &[song|&1])
  end

  def pop(pid) do
    IO.puts "called pop"
    Agent.get(pid, &List.last&1)
  end

    # TODO deal with empty queue
  def playthrough(pid, playhead) do
    head = Queue.pop(pid)
    start_time = :os.system_time(:millisecond)
    Playhead.start_track(playhead, start_time, head)
    # replace with a one-off short-lived timer process that sends a message back when its done
    # (requires a send/recv deal)
    Process.sleep(head.duration_ms)

    playthrough(pid, playhead)
  end

end