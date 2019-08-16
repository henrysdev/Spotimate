defmodule SpotimateWeb.PageController do
  use SpotimateWeb, :controller
  import Ecto.Query

  alias Spotimate.{
    Listening.Room,
    Listening.DataModel.RoomsDAO,
    Utils,
  }

  def index(conn, _params) do
    render(conn, "login.html")
  end

  def user_home(conn, _params) do
    render(conn, "user_home.html")
  end

  def user_rooms(conn, _params) do
    user_id = get_session(conn, :user_id)
    if is_nil(user_id) == false do
      user_rooms = RoomsDAO.get_rooms_created_by_user(user_id)
      render(conn, :user_rooms, rooms: user_rooms)
    else
      conn
      |> put_status(:not_found)
      |> put_view(SpotimateWeb.ErrorView)
      |> render("404.html")
    end
  end

  def room(conn, %{"id" => room_id}) do
    if RoomsDAO.exists?(:id, room_id) do
      conn = put_session(conn, :curr_room, room_id)
      room = RoomsDAO.fetch_by_id(room_id)
      render(conn, :room, room_name: room.name, access_token: Spotify.Cookies.get_access_token(conn))
    else
      conn
      |> put_status(:not_found)
      |> put_view(SpotimateWeb.ErrorView)
      |> render("404.html")
    end
  end

end
