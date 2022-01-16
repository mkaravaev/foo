defmodule Foo.Generator do
  @moduledoc """
  Worker that responsible for reccurence points re-generating.
  and providing API for fetching 2 Users that have points above :max_number

  Initilalized with 
    :max_number - randomly generated integer in range 0-100
    :timestamp - time of last call to API (initial value is nil)


  Available configurations under {:foo, Foo.Generator}:
    disabled: boolean  -- # in case you don't want to start service with app
    interval: microseconds -- # time intervale for reccurence job

  """
  use GenServer

  alias Foo.Users
  alias Foo.Time

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec fetch(timeout :: non_neg_integer()) :: {:ok, [%Foo.User{}]}
  def fetch(timeout \\ 5000) do
    GenServer.call(__MODULE__, :fetch, timeout)
  end

  @spec config(key :: atom()) :: term()
  def config(key) do
    Application.get_env(:foo, Foo.Generator)[key]
  end

  @impl GenServer
  def init(_opts) do
    Process.send_after(self(), :generate, config(:interval))

    {:ok, %{max_number: gen_random(), timestamp: nil}}
  end

  @impl GenServer
  def handle_call(:fetch, _from, %{max_number: max_number, timestamp: prev_timestamp} = state) do
    users = Users.get_2_above_points(max_number)

    {:reply, {:ok, %{users: users, timestamp: prev_timestamp}},
     %{state | timestamp: Time.current()}}
  end

  @impl GenServer
  def handle_info(:generate, state) do
    Users.update_all_points()
    {:noreply, %{state | max_number: gen_random()}}
  end

  defp gen_random do
    :rand.uniform(100)
  end

end
