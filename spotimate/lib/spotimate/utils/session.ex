defmodule Spotimate.Utils.Session do
  import Plug.Conn

  def fetch_multiple(conn, keys_list) do
    res = Enum.reduce(keys_list, %{}, fn k, acc ->
      Map.put(acc, k, get_session(conn, k))
    end)
    res |> IO.inspect()
    res
  end
  
end