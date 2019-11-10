defmodule Spotimate.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :seed_uri, :string
      add :creator_id, :integer

      timestamps()
    end
  end
end
