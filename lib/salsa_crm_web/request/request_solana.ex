defmodule SalsaCrm.RequestSolana do
  @moduledoc """
  This module defines functions used to make request to "Solana".
  """

  # SalsaCrm.RequestSolana.get_account_info("8dpbCuqckiMHF5evhTE4NmbJBKuH9nMQ8GfKMREDMZZs")
  def get_account_info(id) do
    {:ok, key} = Solana.Key.decode(id)
    client = Solana.RPC.client(network: "https://larix.rpcpool.com/b9f4f7c826357818e91fbd79bd85", adapter: {Tesla.Adapter.Httpc, certificates_verification: true})
    case Solana.RPC.send(client, Solana.RPC.Request.get_account_info(key)) do
      {:ok, signature} -> 
        signature
      {:error, error} -> 
        error
    end
  end

  # SalsaCrm.RequestSolana.get_transaction("hola")
  def get_transaction(id) do
    {consult, 0} = System.cmd "solana", [
      "-v",
      "confirm",
      id
    ]
  end
end
  