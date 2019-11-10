defmodule Spotimate.Spotify.Player do
  alias Spotimate.Listening.Room.Playhead

  def play_track(%Playhead{} = playhead, acc_tok, device_id) do
    %Playhead{
      track: track,
      position_ms: position_ms
    } = playhead

    url = "https://api.spotify.com/v1/me/player/play?device_id=#{device_id}"

    body =
      Poison.encode!(%{
        "uris" => [track.uri],
        "position_ms" => position_ms
      })

    headers = [
      {"Authorization", "Bearer #{acc_tok}"},
      {"Content-Type", "application/json"}
    ]

    HTTPoison.put(url, body, headers) |> Spotimate.Utils.HTTP.handle_http_resp()
  end
end
