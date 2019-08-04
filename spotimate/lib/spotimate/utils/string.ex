defmodule Spotimate.Utils.String do
  
  def extract_uri_id(str) do
    String.slice(str, -22, 22)
  end

end