defmodule SpotimateWeb.PageController do
  use SpotimateWeb, :controller
  import Ecto.Query
  alias Spotimate.Rooms.Listening
  alias Spotimate.Rooms.RoomsDAO

  def index(conn, _params) do
    render(conn, "login.html")
  end

  def user_home(conn, _params) do
    render(conn, "user_home.html")
  end

  def user_rooms(conn, _params) do
    user_id = get_session(conn, :user_id)
    if is_nil(user_id) do
      conn
      |> put_status(:not_found)
      |> put_view(SpotimateWeb.ErrorView)
      |> render("404.html")
    else
      user_rooms = Spotimate.Rooms.RoomsDAO.get_rooms_created_by_user(user_id)
      render(conn, :rooms, rooms: user_rooms)
    end
  end

  def room(conn, %{"id" => room_id}) do
    if RoomsDAO.exists?(:id, room_id) do
      conn = put_session(conn, :curr_room, room_id)
      render(conn, :test_playback, access_token: Map.fetch!(conn.req_cookies, "spotify_access_token"))
    else
      conn
      |> put_status(:not_found)
      |> put_view(SpotimateWeb.ErrorView)
      |> render("404.html")
    end
  end

end
