defmodule FooWeb.PageController do
  use FooWeb, :controller

  alias Foo.Generator

  @timeout :timer.seconds(10)

  def index(conn, _params) do
    with {:ok, resp} <- Generator.fetch(@timeout) do
      render(conn, "index.json", resp)
    else
      _error -> {:error, "Can't process request"}
    end
  end
end
