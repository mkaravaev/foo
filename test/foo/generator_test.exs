defmodule Foo.GeneratorTest do
  use Foo.DataCase

  alias Foo.Generator
  alias Foo.User

  @amount_of_users 10

  test "should generate max_number and set timestamp to nil on init" do
    start_supervised!(Generator)

    assert %{max_number: max_number, timestamp: nil} = :sys.get_state(Generator)
    assert max_number in 0..100
  end

  describe "&generate/0" do
    setup do
      add_users(@amount_of_users)
      start_supervised!(Generator)
      :ok
    end

    test "should generate points for all users" do
      assert List.duplicate(0, @amount_of_users) == get_users_points()

      Generator.generate()

      refute List.duplicate(0, @amount_of_users) == get_users_points()
      refute nil in get_users_points()
    end
  end

  describe "&fetch/0" do
    setup do
      start_supervised!(Generator)
      add_users(5, 8)
      add_users(5, 9)
      :ok
    end

    test "should return previous timestamp" do
      assert {:ok, %{timestamp: nil}} = Generator.fetch
      assert %{timestamp: %NaiveDateTime{} = timestamp} = :sys.get_state(Generator)
      assert {:ok, %{timestamp: ^timestamp}} = Generator.fetch
    end

    test "should return 2 users with points above max_number" do
      :sys.replace_state(Generator, fn state -> %{state | max_number: 8} end)
      {:ok, %{users: users}} = Generator.fetch
      assert Enum.count(users) == 2
      assert Enum.map(users, &(&1.points)) == [9,9]
    end
  end

  defp add_users(count, points \\ 0) do
    inserted_at = updated_at = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    chunk = List.duplicate(%{inserted_at: inserted_at, updated_at: updated_at, points: points}, count)

    Repo.insert_all(Foo.User, chunk)
  end

  defp get_users_points() do
    User
    |> Repo.all
    |> Enum.map(&(&1.points))
  end
end
