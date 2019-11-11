defmodule Spotimate.Spotify.Client do
  def refresh(conn) do
    case Spotify.Authentication.refresh(conn) do
      {:ok, conn} -> conn
      error -> error
    end
  end

  def get_playlists(conn, user_id) do
    case Spotify.Playlist.get_users_playlists(conn, user_id, limit: 50) do
      {:ok, resp} -> resp.items
      error -> error
    end
  end

  def get_recommendations(conn, seed_uri, count) do
    case Spotify.Recommendation.get_recommendations(conn,
           seed_tracks: seed_uri,
           limit: count
         ) do
      {:ok, r} -> r.tracks
      _ -> []
    end
  end
end
