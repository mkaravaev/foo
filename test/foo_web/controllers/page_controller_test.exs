defmodule FooWeb.PageControllerTest do
  use FooWeb.ConnCase

  alias Foo.Generator
  alias Foo.Repo

  setup do
    start_supervised!(Generator)
    :sys.replace_state(Generator, fn state -> %{state | max_number: 8} end)
    add_users(10, 10)
    :ok
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert %{"users" => users, "timestamp" => nil} = json_response(conn, 200)
    assert [%{"points" => 10, "id" => _id}, _] = users
  end

  defp add_users(count, points \\ 0) do
    inserted_at = updated_at = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    chunk =
      List.duplicate(%{inserted_at: inserted_at, updated_at: updated_at, points: points}, count)

    Repo.insert_all(Foo.User, chunk)
  end
end
