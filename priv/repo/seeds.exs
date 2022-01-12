# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Foo.Repo.insert!(%Foo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

inserted_at = updated_at = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second) 


chunks =
  List.duplicate(%{inserted_at: inserted_at, updated_at: updated_at, points: 0}, 1_000_000)
  |> Enum.chunk_every(21845)


Foo.Repo.transaction(fn ->
  Task.async_stream(chunks, fn chunk ->
    {count, _} = Foo.Repo.insert_all(Foo.User, chunk)
    count
  end, ordered: false)
  |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)
end)
