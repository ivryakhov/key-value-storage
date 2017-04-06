#Это точка входа в приложение.
defmodule KVstore do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info "Started application"
    KVstore.Supervisor.start_link
  end
end

defmodule KVstore.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    port = Application.get_env(:kvstore, :cowboy_port, 8080)
    
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], port: port),
      worker(Storage, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
