defmodule Spotimate.Listening.Room.Queue do
  use Agent

  def start_link(_opts, init_tracks \\ []) do
    Agent.start_link(fn -> init_tracks end)
  end

  def push(pid, %Spotify.Track{} = song) do
    Agent.update(pid, &[song | &1])
  end

  def pop(pid) do
    Agent.get_and_update(
      pid,
      fn q ->
        {List.last(q), List.delete_at(q, length(q) - 1)}
      end
    )
  end

  def peek(pid), do: Agent.get(pid, &List.last(&1))

  def peek_all(pid), do: Agent.get(pid, & &1)
end
