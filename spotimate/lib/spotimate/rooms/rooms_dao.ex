defmodule Spotimate.Rooms.RoomsDAO do
  import Ecto.Query

  alias Spotimate.{
    Repo,
    Rooms.Room,
  }

  def exists?(:id, val) do
    Repo.exists?(from r in Room, where: r.id == ^val)
  end
  
  def get_rooms_created_by_user(user_id) do
    Repo.all(from r in Room, where: r.creator_id == ^user_id)
  end

  def insert(%Room{} = room) do
    {:ok, room} = Repo.insert(room)
  end

  def fetch_by_id(id), do: Repo.get_by(Room, id: id)

end