defmodule SpotimateWeb.Router do
  use SpotimateWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", SpotimateWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/user/home", PageController, :user_home

    get "/user/rooms", PageController, :rooms

    # TODO clean this up!
    get "/user/rooms/:id", PageController, :room

    # OAuth2 Flow
    get "/login", OAuth2Controller, :login

    get "/callback", OAuth2Controller, :callback

  end

  scope "/api", SpotimateWeb do
    pipe_through :api

    post "/player/browser_device", PlaybackController, :browser_device

    post "/player/play", PlaybackController, :play

    post "/player/pause", PlaybackController, :pause

    get "/user/collab_playlists", SpotifyAPIController, :collab_playlists

  end

end
