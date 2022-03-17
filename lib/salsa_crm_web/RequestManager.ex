defmodule Web.RequestManager do
    import Plug.Conn
    @moduledoc """
    Plug module used to manage authorized and unathorized requests.
    """
  
    alias SalsaCrm.CommonFunctions
  
    # @graphiql_path "/#{
    #   Application.get_env(:api, :router, [])
    #   |> Keyword.get(:graphql_path, "graphiql")
    # }"
  
    @salsa_path ["crm"]
  
    def init(_params) do
      # Do something
    end
  
    def call(conn, args) do
      # IO.inspect(conn, printable_limit: :infinity, limit: :infinity)
      # build_context(conn, args)
      # |> case do
      #   {:ok, conn} -> conn
      # end
      build_context(conn, args)
      |> case do
        {:ok, conn} -> {Application.get_env(:api, :env), conn}
        {:error, conn} -> {:error, conn}
        {:error, conn, code, msg} -> {:error, conn, code, msg}
        %{} = _graphi -> {Application.get_env(:api, :env), conn}
      end
      # |> IO.inspect(label: "Context")
      |> case do
        {nil, conn} ->
          conn 
          #validate_request(conn)
        {:error, conn, code, msg} ->
          resp(conn, code, msg)
          |> send_resp()
          |> halt()
        _error ->
          resp(conn, 500, Poison.encode!(%{error: "Environment wrongly set"}))
          |> send_resp()
          |> halt()
      end
    end
  
    def build_context(conn, _args) do
      context = %{
        host: conn.host,
        request: %{
          headers: conn.req_headers,
          ip: conn.remote_ip,
          path: conn.request_path,
          path_info: conn.path_info,
          method: conn.method,
          date: DateTime.utc_now() |> DateTime.to_iso8601(),
          params: conn.params
        }
      }
  
      access_token = get_access_token(conn)
      # authentication = CommonFunctions.autentication_token(access_token)
  
      conn.path_info
      |> case do
        @salsa_path ->
          {:ok, Absinthe.Plug.put_options(conn, context: context)}
        _default ->
          {:ok, conn}
      end
    end
  
    def auth_validation(conn, _token, query) do
      if String.contains?(query, "IntrospectionQuery") do
        conn
      else
        conn
      end
    end
  
    def get_access_token(conn) do
      headers = conn.req_headers
      key = "Authorization"
      default = ""
  
      Enum.filter(headers, fn {k, _v} ->
        String.equivalent?(String.downcase(k), String.downcase(key))
      end)
      |> Enum.at(0, default)
      |> fn {_key, value} -> value
        _default -> default
      end.()
      |> String.split(" ")
      |> Enum.at(1)
    end
  
    # defp validate_request(conn) do
    #   token = get_access_token(conn)
    #   |> IO.inspect(label: "AccessToken")
  
    #   conn.params["query"]
    #   |> inspect()
    #   |> IO.inspect(label: "Query")
  
    #   if is_nil(token) do
    #     conn
    #     |> resp(403, Poison.encode!(%{ error: "No access token found" }))
    #     |> send_resp()
    #     |> halt()
    #   else
    #     auth_validation(conn, token, conn.params["query"])
    #   end
    # end
  end
  