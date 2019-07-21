defmodule Spotimate.Auth do

    def spotify_authorize_uri do
        auth_param(:authorize_uri)
        <> "?response_type=" <> "code"
        <> "&client_id="     <> auth_param(:client_id)
        <> "&redirect_uri="  <> auth_param(:redirect_uri)
        <> "&scope="         <> auth_param(:scope)
    end

    def get_authentication_response (response_params) do
        # wrap whole body with conditional if csrf token is ==
        url = auth_param(:access_token_uri)
        body = {:form, [
            {:code,          Map.fetch!(response_params, "code")},
            {:grant_type,    "authorization_code"},
            {:client_id,     auth_param(:client_id)},
            {:redirect_uri,  auth_param(:redirect_uri)},
            {:client_id,     auth_param(:client_id)},
            {:client_secret, auth_param(:client_secret)},
        ]}
        HTTPoison.post(url, body, %{}) |> handle_http_resp()
    end

    def refresh_tokens(refresh_token) do
        url = auth_param(:access_token_uri)
        body = {:form, [
            {:grant_type,    "refresh_token"},
            {:refresh_token, refresh_token},
            {:client_id,     auth_param(:client_id)},
            {:client_secret, auth_param(:client_secret)},
        ]}
        HTTPoison.post(url, body, %{}) |> handle_http_resp()
    end

    defp auth_param(key) do
        Application.get_env(:spotimate, key)
    end

    defp handle_http_resp(response) do
        case response do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                body |> Poison.decode!()
            {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
                "400 Bad Request: #{body}"
            _ -> :error
        end
    end

end