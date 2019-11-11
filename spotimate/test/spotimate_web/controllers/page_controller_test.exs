defmodule SpotimateWeb.PageControllerTest do
  use SpotimateWeb.ConnCase

  import Plug.Test
  import Mock

  alias Spotimate.{
    Listening.DataModel.Room,
    Listening.DataModel.RoomsDAO,
    Accounts.DataModel.User,
    Accounts.DataModel.UsersDAO
  }

  @mocked_playlists %Paging{
    items: [
      %Spotify.Playlist{
        name: "Foo"
      },
      %Spotify.Playlist{
        name: "Bar"
      },
      %Spotify.Playlist{
        name: "Zoo"
      }
    ]
  }

  defp dummy_user() do
    test_user = %User{email: "blabla@gmail.com", username: "gertrude"}
    {:ok, user} = UsersDAO.insert(test_user)
    user
  end

  defp dummy_rooms(user_id) do
    rooms = [
      %Room{name: "foobar", creator_id: user_id, seed_uri: "abcdef"},
      %Room{name: "barfoo", creator_id: user_id, seed_uri: "fedasd"}
    ]

    [{:ok, room1}, {:ok, room2}] = Enum.map(rooms, &RoomsDAO.insert(&1))
    [room1, room2]
  end

  # Login
  test "GET / with no valid session prompts login", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Spotimate - Login"
  end

  test "GET / with valid session redirects to home", %{conn: conn} do
    Mock.with_mocks [
      {Spotify.Authentication, [], [refresh: fn c -> {:ok, c} end]},
      {Spotify.Playlist, [], [get_users_playlists: fn _, _, _ -> {:ok, @mocked_playlists} end]}
    ] do
      user = dummy_user()

      conn =
        init_test_session(conn, user_id: user.id)
        |> get("/")

      assert html_response(conn, 200) =~ "Spotimate - Home"
    end
  end

  # Home
  test "GET /home", %{conn: conn} do
    Mock.with_mocks [
      {Spotify.Authentication, [], [refresh: fn c -> {:ok, c} end]},
      {Spotify.Playlist, [], [get_users_playlists: fn _, _, _ -> {:ok, @mocked_playlists} end]}
    ] do
      user = dummy_user()

      conn =
        init_test_session(conn, user_id: user.id)
        |> get("/home")

      assert html_response(conn, 200) =~ "Spotimate - Home"
    end
  end

  test "GET /home with no valid session prompts login", %{conn: conn} do
    conn = get(conn, "/home")
    assert html_response(conn, 200) =~ "Spotimate - Login"
  end

  # User Rooms
  test "GET /rooms", %{conn: conn} do
    user = dummy_user()
    rooms = dummy_rooms(user.id)

    conn =
      init_test_session(conn, user_id: user.id)
      |> get("/rooms")

    assert html_response(conn, 200) =~ "Spotimate - Rooms"
    Enum.each(rooms, fn r -> assert(html_response(conn, 200)) =~ r.name end)
  end

  test "GET /rooms with no valid session prompts login", %{conn: conn} do
    conn = get(conn, "/rooms")
    assert html_response(conn, 200) =~ "Spotimate - Login"
  end

  # Room
  test "GET /rooms/:id", %{conn: conn} do
    user = dummy_user()
    [room, _] = dummy_rooms(user.id)

    conn =
      init_test_session(conn, user_id: user.id)
      |> get("/rooms/#{room.id}")

    assert html_response(conn, 200) =~ "Spotimate - #{room.name}"
  end

  test "GET /rooms/:id with no valid room id returns not found", %{conn: conn} do
    user = dummy_user()

    conn =
      init_test_session(conn, user_id: user.id)
      |> get("/rooms/123")

    assert html_response(conn, 404) =~ "Not Found"
  end

  test "GET /rooms/:id with no valid session prompts login", %{conn: conn} do
    conn = get(conn, "/rooms/123")
    assert html_response(conn, 200) =~ "Spotimate - Login"
  end
end
