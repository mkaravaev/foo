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
#
alias Foo.Repo
alias Foo.Time
alias Foo.User

Repo.delete_all(User)

inserted_at = updated_at = Time.current()

# NOTE we use 21845 chunk size because insert_all allowed to update only 65535 params at once
chunks =
  %{inserted_at: inserted_at, updated_at: updated_at, points: 0}
  |> List.duplicate(1_000_000)
  |> Enum.chunk_every(21845)

Repo.transaction(fn ->
  Task.async_stream(
    chunks,
    fn chunk ->
      {count, _} = Repo.insert_all(User, chunk)
      count
    end,
    ordered: false
  )
  |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)
end)
