defmodule Spotimate.Listening.RecGenerators do
  alias Spotimate.Utils
  
  def spotify_recs(conn, seed_uri, count) do
    fn ->
      case Spotify.Recommendation.get_recommendations(
        conn,
        seed_tracks: Utils.String.extract_uri_id(seed_uri),
        limit: count)
      do
        {:ok, r} -> r.tracks
        _        -> []
      end
    end
  end

  def static_recs(count) do
    fn -> List.duplicate(%Spotify.Track{
      duration_ms: 1000,
    }, count) end
  end

end