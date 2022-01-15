defmodule Foo.Generator do
  alias Foo.Repo
  alias Foo.User

  import Ecto.Query

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    Process.send_after(self(), :generate, config(:recurrence_timeout))

    {:ok, %{max_number: gen_random(), timestamp: nil}}
  end

  def fetch(timeout \\ 5000) do
    GenServer.call(__MODULE__, :fetch, timeout)
  end

  def generate do
    Ecto.Adapters.SQL.query!(Foo.Repo, "UPDATE users SET points = FLOOR(RANDOM() * 100), updated_at = '#{current_time}'")
  end

  def handle_call(:fetch,  _from, %{max_number: max_number, timestamp: prev_timestamp} = state) do
    query = from u in User,
      where: u.points > ^max_number,
      limit: 2

    users = Repo.all(query)

    {:reply, {:ok, %{users: users, timestamp: prev_timestamp}}, %{state| timestamp: current_time()}}
  end

  def handle_info(:generate, state) do
    {:noreply, %{state| max_number: gen_random()}}
  end

  defp gen_random do
    :rand.uniform(100)
  end

  defp current_time() do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second) 
  end

  def config(key) do
    Application.get_env(:foo, Foo.Generator)[key]
  end

end
