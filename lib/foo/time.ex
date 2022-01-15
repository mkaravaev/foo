defmodule Foo.Time do
  def current do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end
end
