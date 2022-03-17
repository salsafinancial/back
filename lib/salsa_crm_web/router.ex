defmodule SalsaCrmWeb.Router do
  @moduledoc """
  Module that defines the `pipelines` and `scopes` of access for the application.
  """
  use SalsaCrmWeb, :router

  @graphiql_path "/#{
    Application.get_env(:api, :router, [])
    |> Keyword.get(:graphql_path, "graphiql")
  }"

  @salsa_path "/#{
    Application.get_env(:api, :router, [])
    |> Keyword.get(:salsa_path, "crm")
  }"

  pipeline :api do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
      pass: ["*/*"],
      json_decoder: Poison
    plug :accepts, ["json"]
    plug Web.RequestManager
  end

  scope "/" do
    pipe_through :api

    # GrapqhQL UI
    forward @graphiql_path, Absinthe.Plug.GraphiQL,
      schema: SalsaCrmWeb.Schema.Crm,
      json_codec: Poison,
      interface: :simple

    # Neia path
    forward @salsa_path, Absinthe.Plug,
      schema: SalsaCrmWeb.Schema.Crm,
      json_codec: Poison
  end

  # Other scopes may use custom stacks.
  # scope "/api", SalsaCrmWeb do
  #   pipe_through :api
  # end
end
