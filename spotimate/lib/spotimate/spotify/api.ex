defmodule Spotimate.Spotify.API do

  # TODO abstract away boilerplate

  def play_song(acc_tok, device_id) do
    url = "https://api.spotify.com/v1/me/player/play?device_id=#{device_id}"
    headers = [
      {"Authorization", "Bearer #{acc_tok}"},
      {"Content-Type", "application/json"},
    ]
    HTTPoison.put(url, [], headers) |> Spotimate.Utils.HTTP.handle_http_resp()
  end
  def play_song(acc_tok, context_uri, position_ms, device_id) do
    url = "https://api.spotify.com/v1/me/player/play?device_id=#{device_id}"
    body = Poison.encode!(%{
      "context_uri" => context_uri,
      "position_ms" => position_ms,
    })
    headers = [
      {"Authorization", "Bearer #{acc_tok}"},
      {"Content-Type", "application/json"},
    ]
    HTTPoison.put(url, body, headers) |> Spotimate.Utils.HTTP.handle_http_resp()
  end

  def pause_song(acc_tok) do
    url = "https://api.spotify.com/v1/me/player/pause"
    headers = [
      {"Authorization", "Bearer #{acc_tok}"},
      {"Content-Type", "application/json"},
    ]
    HTTPoison.put(url, [], headers) |> Spotimate.Utils.HTTP.handle_http_resp()
  end

  def user_info(acc_tok) do
    url = "https://api.spotify.com/v1/me/"
    headers = [
      {"Authorization", "Bearer #{acc_tok}"},
      {"Content-Type", "application/json"},
    ]
    HTTPoison.get(url, headers) |> Spotimate.Utils.HTTP.handle_http_resp()
  end

  def recommendations(acc_tok, seed_tracks) do
    url = "https://api.spotify.com/v1/recommendations/"
    body = Poison.encode!(%{
      "seed_tracks" => seed_tracks,
      "limit"       => 100,
    })
    headers = [
      {"Authorization", "Bearer #{acc_tok}"},
      {"Content-Type", "application/json"},
    ]
    HTTPoison.get(url, body, headers) |> Spotimate.Utils.HTTP.handle_http_resp()
  end
  
end