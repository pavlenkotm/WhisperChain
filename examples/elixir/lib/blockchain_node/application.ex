defmodule BlockchainNode.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {BlockchainNode, []}
    ]

    opts = [strategy: :one_for_one, name: BlockchainNode.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
