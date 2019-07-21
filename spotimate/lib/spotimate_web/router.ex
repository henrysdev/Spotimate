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
  end

  scope "/", SpotimateWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/home", PageController, :home

    # OAuth2 Flow
    get "/login", OAuth2Controller, :login

    get "/callback", OAuth2Controller, :callback
  end

  scope "/api", SpotimateWeb do
    pipe_through :api
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpotimateWeb do
  #   pipe_through :api
  # end
end
