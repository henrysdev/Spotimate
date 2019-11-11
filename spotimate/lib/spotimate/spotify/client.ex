defmodule Spotimate.Spotify.Client do
  # TODO hold state of when they actually need to be refreshed
  defp refresh_if_necessary(conn) do
    case Spotify.Authentication.refresh(conn) do
      {:ok, conn} -> conn
      error -> error
    end
  end

  def get_playlists(conn, user_id, bulk \\ true) do
    conn = refresh_if_necessary(conn)

    case Spotify.Playlist.get_users_playlists(conn, user_id, limit: 50) do
      {:ok, resp} -> resp.items
      error -> error
    end
  end

  def get_recommendations(conn, seed_uri, count) do
    conn = refresh_if_necessary(conn)

    case Spotify.Recommendation.get_recommendations(conn,
           seed_tracks: seed_uri,
           limit: count
         ) do
      {:ok, r} -> r.tracks
      _ -> []
    end
  end
end
