defmodule Spotimate.Utils.HTTP do
  def handle_http_resp(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> Poison.decode!()

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        "400 Bad Request: #{body}"

      {:ok, %HTTPoison.Response{status_code: 401, body: body}} ->
        "401 Unauthorized: #{body}"

      other ->
        other
    end
  end
end
