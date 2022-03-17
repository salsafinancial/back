defmodule  SalsaCrm.Filters.Manager do
    @moduledoc """
    Defines all the required behaviour to query on a database according to some input parameters.
  
    The input is managed as a massive call that is dispatched to all the filter modules
    ```
    Api.Filters.BusinessFilter
    Api.Filters.InvoiceFilter
    Api.Filters.CreditNoteFilter
    Api.Filters.DebitNoteFilter
    ```
    in an "Observer Pattern-like" behaviour.
    """
    import Ecto.Query, warn: false
    alias SalsaCrm.Repo
  
    @filters [
      SalsaCrm.Filters.Salsa.Transaction,
      SalsaCrm.Filters.Salsa.Account
    ]
  
    @doc """
    Returns an `Ecto.Query` result if a filter module can handle it or an error
    message as `{:error, message}` if no module resolved the call.
  
    This function receives the `event` structure in a map like
    ```
    %{
      :filter => The filter options structred as a map
      :model  => The schema used for that filter
      :list?  => Boolean value to specify if the result should be a list or a single element
      :paginator => Map with the paginator parameters
    }
    ```
  
    Then usign a `for` definition
    ```
    result = Enum.filter(for filter <- @filters do
          filter.manage_event(event)
        end, & !is_nil(&1))
    ```
    Calls the `manage_event/1` of each filter module with the `event` structure. The result is a `model` struct for singleton queries and a Scrivener paginator for listing queries.
    """
    def notify_all(event, order) do
      # Call the required filter
      result =
        Enum.filter(for filter <- @filters do
          filter.manage_event(event, order) end,
          & !is_nil(&1))
      if event.list? do
        if length(result) == 1 do
          query =
            result
            |> Enum.at(0)
          paginator = SalsaCrm.Filters.Paginator.new(event.paginator)
          if is_integer(paginator.page_number) and is_number(paginator.page_size) do
            result =
              query
              |> Repo.paginate(page: paginator.page_number, page_size: paginator.page_size)
            if result.total_pages >= paginator.page_number do
              {:ok, result}
            else
              {:error, SalsaCrm.Filters.Paginator.new(%{page_number: -1})}
            end
          else
            {:error, paginator}
          end
        else
          {:error, "No response from registered modules"}
        end
      else
        if length(result) == 1 do
          # {"invoices", result |> Enum.at(0)}
          result
          |> Enum.at(0)
          |> Repo.one
        else
          {:error, "No response from registered modules"}
        end
      end
    end
  end
  