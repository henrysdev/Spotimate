defmodule SpotimateWeb.PageController do
  use SpotimateWeb, :controller

  def index(conn, _params) do
    render(conn, "login_index.html")
  end

  def home(conn, _params) do
    access_token = get_session(conn, :access_token)
    render(conn, "home.html")
  end

  def fetch_session_date(conn, key) do
    get_session(conn, key)
  end

end
