defmodule Spotimate.Listening.RoomTest do
  use SpotimateWeb.ConnCase

  import Plug.Test
  import Mock

  alias Spotimate.{
    Accounts.DataModel.User,
    Accounts.DataModel.UsersDAO,
    Listening.DataModel,
    Listening.Room
  }

  @mocked_recs %Spotify.Recommendation{
    tracks: [
      %Spotify.Track{
        name: "Foo",
        duration_ms: 2000
      }
    ]
  }

  defp dummy_user() do
    test_user = %User{email: "blabla@gmail.com", username: "gertrude"}
    {:ok, user} = UsersDAO.insert(test_user)
    user
  end

  describe "new room" do
    test "create a new room", %{conn: conn} do
      user = dummy_user()
      room = Room.new_room("cool people only", user.id, "reallygoodtrack")
      assert DataModel.RoomsDAO.exists?(:id, room.id)
    end
  end

  describe "spawn room" do
    test "spawn a room", %{conn: conn} do
      with_mocks([
        {Spotify.Recommendation, [], [get_recommendations: fn c, _ -> {:ok, @mocked_recs} end]}
      ]) do
        user = dummy_user()
        room = Room.new_room("cool people only", user.id, "reallygoodtrack")
        Room.spawn_room(conn, room.id)
      end
    end
  end
end
