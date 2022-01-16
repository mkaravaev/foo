defmodule Foo.User.Query do
  @moduledoc """
  Module responsible for handling Ecto queries for User schema.
  Helping make Ecto queries composable in future.
  """
  import Ecto.Query

  alias Foo.User

  def get_above_points(query \\ User, threshold) do
    where(query, [u], u.points > ^threshold)
  end
end
