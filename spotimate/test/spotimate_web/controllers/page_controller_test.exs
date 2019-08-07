defmodule SpotimateWeb.PageControllerTest do
  use SpotimateWeb.ConnCase
  import Plug.Test
  alias Spotimate.Rooms.Room
  alias Spotimate.Rooms.RoomsDAO
  alias Spotimate.Accounts.User
  alias Spotimate.Accounts.UsersDAO

  defp dummy_user() do
    test_user = %User{email: "blabla@gmail.com", username: "gertrude"}
    {:ok, user} = UsersDAO.insert(test_user)
    user
  end
  
  defp dummy_rooms(user_id) do
    rooms = [%Room{name: "foobar", creator_id: user_id, seed_uri: "abcdef"},
             %Room{name: "barfoo", creator_id: user_id, seed_uri: "fedasd"}]
    [{:ok, room1}, {:ok, room2}] = Enum.map(rooms, &RoomsDAO.insert(&1))
    [room1, room2]
  end


  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Spotimate - Login"
  end

  test "GET /user/home", %{conn: conn} do
    conn = get(conn, "/user/home")
    assert html_response(conn, 200) =~ "Spotimate - Home"
  end

  test "GET /user/rooms", %{conn: conn} do
    user = dummy_user()
    rooms = dummy_rooms(user.id)
    conn = conn
    |> init_test_session(foo: "bar")
    |> put_session(:user_id, 0)
    |> get("/user/rooms")
    assert html_response(conn, 200) =~ "Spotimate - Rooms"
  end

  test "GET /user/rooms with no valid user_id", %{conn: conn} do
    conn = get(conn, "/user/rooms")
    assert html_response(conn, 404) =~ "Not Found"
  end

  test "GET /user/rooms/:id", %{conn: conn} do
    user = dummy_user()
    [room1, room2] = dummy_rooms(user.id)
    # conn = conn
    # |> init_test_session(foo: "bar")
    # |> put_session("spotify_access_token", "asdf")
    # |> get("/user/rooms/#{room1.id}")
  end

  

end
