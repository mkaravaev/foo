defmodule FooWeb.PageController do
  use FooWeb, :controller
  alias Foo.Generator

  def index(conn, _params) do
    with {:ok, resp} <- Generator.fetch() do
      render(conn, "index.json", resp)
    else
      _error  -> {:error, "Can't process request"}
    end
  end
end
