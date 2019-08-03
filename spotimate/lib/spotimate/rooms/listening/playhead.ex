defmodule Spotimate.Rooms.Listening.Playhead do
  use Agent
  alias Spotimate.Rooms.Listening.Playhead
  alias Spotimate.Spotify

  defstruct song: %Spotify.Song{},
            position_ms: 0,
            start_time: 0,
            time_calculated: 0

  def start_link(_opts) do
    Agent.start_link(fn -> %Playhead{} end)
  end

  def start_track(pid, start_time, song) do
    Agent.update(pid, &Map.put(&1, "start_time", start_time))
    Agent.update(pid, &Map.put(&1, "song", song))
  end

  def fetch(pid) do
    song       = Agent.get(pid, &Map.get(&1, "song"))
    start_time = Agent.get(pid, &Map.get(&1, "start_time"))
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
      {:error, nil}
    end
  end

end