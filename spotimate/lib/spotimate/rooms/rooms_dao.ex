defmodule Spotimate.Rooms.RoomsDAO do
  alias Spotimate.Repo
  alias Spotimate.Rooms.Room
  import Ecto.Query

  def exists?(:id, val) do
    Repo.exists?(from r in Room, where: r.id == ^val)
  end
  
  def get_rooms_created_by_user(user_id) do
    Repo.all(from r in Room, where: r.creator_id == ^user_id)
  end

  def insert(%Room{} = room) do
    {:ok, room} = Repo.insert(room)
  end

  def fetch_by_attr(:id, val), do: Repo.get_by(Room, id: val)

end