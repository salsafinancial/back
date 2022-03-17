defmodule SalsaCrm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      SalsaCrm.Repo,
      # Start the endpoint when the application starts
      SalsaCrmWeb.Endpoint,
      # Starts a worker by calling: SalsaCrm.Worker.start_link(arg)
      {Phoenix.PubSub, [name: SalsaCrm.PubSub, adapter: Phoenix.PubSub.PG2]},
      # {SalsaCrm.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SalsaCrm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SalsaCrmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
