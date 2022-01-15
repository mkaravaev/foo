defmodule Foo.GeneratorTest do
  use Foo.DataCase

  alias Foo.Generator
  alias Foo.User

  @amount_of_users 10

  setup do
    add_users(@amount_of_users)
    start_supervised!(Generator)
    :ok
  end

  test "should generate max_number and set timestamp to nil on init" do
    assert %{max_number: max_number, timestamp: nil} = :sys.get_state(Generator)
    assert max_number in 0..100
  end

  test "should generate and update points for all users" do
    assert List.duplicate(0, @amount_of_users) == get_users_points()

    send(Generator, :generate)
    :timer.sleep(300)

    refute List.duplicate(0, @amount_of_users) == get_users_points()
    refute nil in get_users_points()
  end

  describe "&fetch/0" do
    setup do
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

  defp add_users(amount_of_users, points \\ 0) do
    inserted_at = updated_at = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    chunk = List.duplicate(%{inserted_at: inserted_at, updated_at: updated_at, points: points}, amount_of_users)

    Repo.insert_all(Foo.User, chunk)
  end

  defp get_users_points() do
    User
    |> Repo.all
    |> Enum.map(&(&1.points))
  end
end
