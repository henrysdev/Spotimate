defmodule SpotimateWeb.PageController do
  use SpotimateWeb, :controller

  alias Spotimate.{
    Spotify.Client,
    Listening.DataModel.RoomsDAO,
    Utils.Time
  }

  # *** Session Utils ***
  defp refresh_if_necessary(conn) do
    token_expiry = get_session(conn, :token_expiry)

    if Time.now_utc_millis() > token_expiry do
      IO.puts("Token Expired. Refreshing...")

      conn
      |> Client.refresh()
      |> put_session(:token_expiry, Time.future_utc_millis(60 * 20 * 1000))
    else
      conn
    end
  end

  defp logged_in?(conn) do
    case get_session(conn, :user_id) do
      nil -> false
      _user_id -> true
    end
  end

  # *** Endpoints ***
  def index(conn, params) do
    if logged_in?(conn) do
      user_home(conn, params)
    else
      render(conn, "login.html")
    end
  end

  def user_home(conn, _params) do
    if logged_in?(conn) do
      conn = refresh_if_necessary(conn)
      username = get_session(conn, :username)
      playlists = Client.get_playlists(conn, username)
      render(conn, :user_home, playlists: playlists)
    else
      render(conn, "login.html")
    end
  end

  def user_rooms(conn, _params) do
    if logged_in?(conn) do
      conn = refresh_if_necessary(conn)
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
        conn =
          conn
          |> refresh_if_necessary()
          |> put_session(:curr_room, room_id)

        room = RoomsDAO.fetch_by_id(room_id)
        access_token = Spotify.Cookies.get_access_token(conn)

        render(conn, :room,
          room_name: room.name,
          room_id: room_id,
          access_token: access_token
        )
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
