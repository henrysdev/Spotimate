defmodule Spotimate.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :creator_id, :integer
    field :current_track, :string
    field :next_track, :string
    field :track_started, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:creator_id, :current_track, :next_track, :track_started])
    |> validate_required([:creator_id, :current_track, :next_track, :track_started])
  end
end
