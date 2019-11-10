defmodule SpotimateWeb.PageController do
  use SpotimateWeb, :controller
  import Ecto.Query

  alias Spotimate.{
    Listening.Room,
    Listening.DataModel.RoomsDAO,
    Utils,
  }

  # TODO move to utils or change into decorator-style macro
  defp logged_in?(conn) do
    case get_session(conn, :user_id) do
      nil     -> false
      user_id -> true
    end
  end

  def index(conn, params) do
    if logged_in?(conn) do
      user_home(conn, params)
    else
      render(conn, "login.html")
    end
  end

  def user_home(conn, _params) do
    if logged_in?(conn) do
      render(conn, "user_home.html")
    else
      render(conn, "login.html")
    end
  end

  def user_rooms(conn, _params) do
    # TODO find a better way than nested if else...
    if logged_in?(conn) do
      user_id = get_session(conn, :user_id)
      user_rooms = RoomsDAO.get_rooms_created_by_user(user_id)
      render(conn, :user_rooms, rooms: user_rooms)
    else
      render(conn, "login.html")
    end
  end

  def room(conn, %{"id" => room_id}) do
    if logged_in?(conn) do
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
    else
      render(conn, "login.html")
    end
  end

end
