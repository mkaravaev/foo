defmodule FooWeb.PageView do
  use FooWeb, :view

  def render("index.json", %{users: users, timestamp: timestamp}) do
    %{
      users: render_many(users, __MODULE__, "user.json", as: :user),
      timestamp: timestamp
    }
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, points: user.points}
  end
end
