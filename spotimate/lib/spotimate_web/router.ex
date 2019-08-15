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

    # HTML Page Controller
    get "/", PageController, :index

    get "/home", PageController, :user_home

    get "/rooms", PageController, :user_rooms

    get "/rooms/:id", PageController, :room

    # OAuth2 Flow
    get "/login", AuthController, :login

    get "/callback", AuthController, :callback

  end

  scope "/api", SpotimateWeb do
    pipe_through :api

    post "/room/new", RoomController, :new_room

    post "/room/listen", RoomController, :listen

    put "/room/sync_playhead", RoomController, :sync_playhead

  end

end
