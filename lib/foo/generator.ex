defmodule Foo.Generator do
  use GenServer

  alias Foo.Users
  alias Foo.Time

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    Process.send_after(self(), :generate, config(:interval))

    {:ok, %{max_number: gen_random(), timestamp: nil}}
  end

  def fetch(timeout \\ 5000) do
    GenServer.call(__MODULE__, :fetch, timeout)
  end

  def handle_call(:fetch, _from, %{max_number: max_number, timestamp: prev_timestamp} = state) do
    users = Users.get_2_above_points(max_number)

    {:reply, {:ok, %{users: users, timestamp: prev_timestamp}},
     %{state | timestamp: Time.current()}}
  end

  def handle_info(:generate, state) do
    Users.update_all_points()
    {:noreply, %{state | max_number: gen_random()}}
  end

  defp gen_random do
    :rand.uniform(100)
  end

  def config(key) do
    Application.get_env(:foo, Foo.Generator)[key]
  end
end
