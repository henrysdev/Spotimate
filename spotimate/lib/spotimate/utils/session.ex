defmodule Spotimate.Utils.Session do
  import Plug.Conn

  def fetch_multiple(conn, keys_list) do
    Enum.reduce(keys_list, %{}, fn k, acc ->
      Map.put(acc, k, get_session(conn, k))
    end)
  end
  
end