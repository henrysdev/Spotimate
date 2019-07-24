defmodule Spotimate.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :creator_id, :integer
      add :current_track, :string
      add :next_track, :string
      add :track_started, :utc_datetime

      timestamps()
    end

  end
end
