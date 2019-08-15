defmodule SpotimateWeb.PageControllerTest do
  use SpotimateWeb.ConnCase
  
  import Plug.Test

  alias Spotimate.{
    Rooms.Room,
    Rooms.RoomsDAO,
    Accounts.User,
    Accounts.UsersDAO,
  }

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

  test "GET /home", %{conn: conn} do
    conn = get(conn, "/home")
    assert html_response(conn, 200) =~ "Spotimate - Home"
  end

  test "GET /rooms", %{conn: conn} do
    user = dummy_user()
    rooms = dummy_rooms(user.id)
    conn = init_test_session(conn, user_id: user.id)
    |> get("/rooms")
    assert html_response(conn, 200) =~ "Spotimate - Rooms"
    Enum.each(rooms, fn r -> assert(html_response(conn, 200)) =~ r.name end)
  end

  test "GET /rooms with no valid user_id", %{conn: conn} do
    conn = get(conn, "/rooms")
    assert html_response(conn, 404) =~ "Not Found"
  end

  test "GET /rooms/:id", %{conn: conn} do
    user = dummy_user()
    [room, _] = dummy_rooms(user.id)
    conn = init_test_session(conn, foo: "bar")
    |> get("/rooms/#{room.id}")
    assert html_response(conn, 200) =~ "Spotimate - #{room.name}"
  end

end
