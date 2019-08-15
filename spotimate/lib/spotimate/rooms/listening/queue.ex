defmodule Spotimate.Rooms.Listening.Queue do
  use Agent
  
  alias Spotimate.Rooms.Listening.{
    Playhead,
    Queue,
  }

  def start_link(_opts, init_contents \\ []) do
    Agent.start_link(fn -> init_contents end)
  end

  def push(pid, %Spotify.Track{} = song) do
    Agent.update(pid, &[song|&1])
  end

  def pop(pid) do
    IO.puts "start next song"
    Agent.get_and_update(pid,
      fn q -> 
        {List.last(q), List.delete_at(q, length(q)-1)}
      end)
  end

  def peek(pid) do
    Agent.get(pid, &List.last&1)
  end

  def peek_all(pid) do
    Agent.get(pid, &(&1))
  end

end