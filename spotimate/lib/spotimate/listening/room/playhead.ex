defmodule Spotimate.Listening.Room.Playhead do
  use Agent
  
  alias Spotimate.{
    Listening.Room.Queue,
    Listening.Room.Playhead,
    Utils.Time,
  }

  defstruct track: %Spotify.Track{},
            position_ms: 0,
            deadline_utc: 0,
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
    play_next(pid, queue_pid)
  end

  # Recursive play loop
  def play_next(pid, queue_pid, counter \\ 0) do
    case Queue.pop(queue_pid) do
      %Spotify.Track{} = track ->
        # Start track
        deadline_utc = Time.now_utc_millis() + track.duration_ms
        start_track(pid, deadline_utc, track)
        # Spawn timer process for track duration
        spawn fn ->
          Time.delayed_action(track.duration_ms, fn ->
            play_next(pid, queue_pid, counter + 1)
          end)
        end

      _ -> {:error, "Queue Exhausted. Track Counter: #{counter}"}
    end
  end

  defp start_track(pid, deadline_utc, track) do
    Agent.update(pid, &Map.put(&1, "deadline_utc", deadline_utc))
    Agent.update(pid, &Map.put(&1, "track", track))
  end

  def fetch(pid) do
    track        = Agent.get(pid, &Map.get(&1, "track"))
    deadline_utc = Agent.get(pid, &Map.get(&1, "deadline_utc"))
    now_utc = Time.now_utc_millis()
    position_ms = track.duration_ms - (deadline_utc - now_utc)
    if position_ms < track.duration_ms do
      %Playhead{
        track:           track,
        position_ms:     position_ms,
        deadline_utc:    deadline_utc,
        time_calculated: now_utc,
      }
    else
      # Have process die / supervisor replace
     {:error, "Expired Playhead"}
    end
  end

end