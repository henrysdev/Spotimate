defmodule SpotimateWeb.PageController do
  use SpotimateWeb, :controller
  import Ecto.Query
  alias Spotimate.Rooms.Listening
  alias Spotimate.Rooms.RoomsDAO

  def index(conn, _params) do
    render(conn, "login.html")
  end

  def user_home(conn, _params) do
    acc_tok = get_session(conn, :access_token)
    ref_tok = get_session(conn, :refresh_token)
    render(conn, :user_home, refresh_token: ref_tok, access_token: acc_tok)
  end

  def user_rooms(conn, _params) do
    user_id = get_session(conn, :user_id)
    user_rooms = Spotimate.Rooms.RoomsDAO.get_rooms_created_by_user(user_id)
    render(conn, :rooms, rooms: user_rooms)
  end

  def room(conn, %{"id" => room_id}) do
    conn = put_session(conn, :curr_room, room_id)
    render(conn, :test_playback, access_token: get_session(conn, :access_token))
  end

end
