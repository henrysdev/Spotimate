defmodule Spotimate.Rooms.RoomsDAO do
  alias Spotimate.Repo
  alias Spotimate.Rooms.Room
  import Ecto.Query

  def get_rooms_created_by_user(user_id) do
    Repo.all(from r in Room, where: r.creator_id == 2)
  end

end