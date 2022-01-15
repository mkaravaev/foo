defmodule Foo.User.Query do
  import Ecto.Query

  alias Foo.User

  def get_above_points(query \\ User, threshold) do
    where(query, [u], u.points > ^threshold)
  end
end
