defmodule  SalsaCrm.Filters.Event do
    defstruct [:filter, :model, :list?, :paginator]
    @moduledoc """
    This module defines the creation for a filter event. A filter event is a structure
    that contains all the required information for a specific query. Usually it will have:
    - 'filter': The filter struct for a query
    - 'model': The model reference used to build the query
    - 'list?': A parameter to differentiate listing queries from single result queries.
    - 'paginator': Map with parameters used to build the paginator.
    """
  
    @doc """
      Function for filter event creation.
  
      If no paginator is defined, it is set with a default 'page_size' of 10 starting on 'page_number' 1.
    """
    def new(filter, model, list?, paginator) do
      % SalsaCrm.Filters.Event{
        filter: filter,
        model: model,
        list?: list?,
        paginator: paginator
      }
    end
    def new(filter, model, list?) do
      % SalsaCrm.Filters.Event{
        filter: filter,
        model: model,
        list?: list?,
        paginator: %{page_size: 10, page_number: 1}
      }
    end
  end
  