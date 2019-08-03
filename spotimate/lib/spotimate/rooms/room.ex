defmodule Spotimate.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :creator_id, :integer
    field :seed_uri, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :creator_id, :seed_uri])
    |> validate_required([:name, :creator_id, :seed_uri])
  end
end
