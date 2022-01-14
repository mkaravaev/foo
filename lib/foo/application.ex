defmodule Foo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Foo.Repo,
      # Start the Telemetry supervisor
      FooWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Foo.PubSub},
      # Start the Endpoint (http/https)
      FooWeb.Endpoint
      # Start a worker by calling: Foo.Worker.start_link(arg)
      # {Foo.Worker, arg}
    ] |> maybe_start_generator()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Foo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp maybe_start_generator(children) do
    if Foo.Generator.config(:disabled) do
      children
    else
      children ++ [Foo.Generator]
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FooWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
