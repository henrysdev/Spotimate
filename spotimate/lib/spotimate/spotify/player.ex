defmodule Spotimate.Spotify.Player do
  alias Spotimate.Rooms.Listening.Playhead
  
  def play_track(acc_tok, device_id, %Playhead{} = playhead) do
    %Playhead{
      song: %Spotify.Track{
        uri: uri,
      },
      position_ms: position_ms,
    } = playhead
    url = "https://api.spotify.com/v1/me/player/play?device_id=#{device_id}"
    IO.inspect uri
    IO.inspect device_id
    IO.inspect position_ms
    body = Poison.encode!(%{
      "uris" => [uri],
      "position_ms" => position_ms,
    })
    headers = [
      {"Authorization", "Bearer #{acc_tok}"},
      {"Content-Type", "application/json"},
    ]
    HTTPoison.put(url, body, headers) |> Spotimate.Utils.HTTP.handle_http_resp()
  end

end