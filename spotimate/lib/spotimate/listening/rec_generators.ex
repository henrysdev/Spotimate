defmodule Spotimate.Listening.RecGenerators do
  alias Spotimate.{
    Spotify.Client,
    Utils
  }

  @doc """
  Returns a function for sending a batch request
  for getting recommended tracks.
  Plug.Conn -> String -> Integer -> (fn -> [Track])
  """
  def spotify_recs(conn, seed_uri, count) do
    fn ->
      Client.get_recommendations(conn, Utils.String.extract_uri_id(seed_uri), count)
    end
  end
end
