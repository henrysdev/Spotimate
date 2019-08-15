defmodule SpotimateWeb.RoomController do
  use SpotimateWeb, :controller

  alias Spotimate.{
    Rooms.Listening,
    Spotify.Player,
    Utils.Session,
  }

  def listen(conn, %{"device_id" => device_id}) do
    # Persist device id with session
    conn = put_session(conn, :device_id, device_id)

    %{
      :curr_room => room_id,
      :user_id   => user_id,
      :device_id => device_id,
    } = Session.fetch_multiple(conn, [:curr_room, :user_id, :device_id])

    # acc_tok = Map.get(conn.cookies, "spotify_access_token")
    acc_tok = Spotify.Cookies.get_access_token(conn)

    # Determine if there is a live playhead process already spawned.
    playhead = Listening.obtain_playhead(conn, room_id, user_id)

    # Trigger player
    resp = Player.play_track(acc_tok, device_id, playhead)
    resp |> IO.inspect()

    json(conn, Poison.encode!%{
      "deadline_utc" => playhead.deadline_utc,
    })
  end

  def new_room(conn, %{"name" => name, "seed_uri" => seed_uri}) do
    creator_id = get_session(conn, :user_id)
    Listening.new_room(conn, name, creator_id, seed_uri)
  end

  def sync_playhead(conn, _params) do
    %{
      :curr_room => room_id,
      :user_id   => user_id,
      :device_id => device_id,
    } = Session.fetch_multiple(conn, [:curr_room, :user_id, :device_id])

    # acc_tok = Map.get(conn.cookies, "spotify_access_token")
    acc_tok = Spotify.Cookies.get_access_token(conn)

    # Determine if there is a live playhead process already spawned.
    playhead = Listening.obtain_playhead(conn, room_id, user_id)

    # Trigger player
    Player.play_track(acc_tok, device_id, playhead)

    IO.puts "DEADLINE_UTC"
    IO.inspect playhead.deadline_utc

    json(conn, Poison.encode!%{
      "deadline_utc" => playhead.deadline_utc,
    })
  end

end
