defmodule Foo.Users do
  import Ecto.Query

  alias Foo.Repo
  alias Foo.Time
  alias Foo.User.Query

  def update_all_points  do
    Ecto.Adapters.SQL.query!(Repo, "UPDATE users SET points = FLOOR(RANDOM() * 100), updated_at = '#{Time.current}'")
  end

  def get_2_above_points(points) do
    Query.get_above_points(points)
    |> limit(2)
    |> Repo.all
  end

end
