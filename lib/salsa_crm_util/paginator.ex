defmodule  SalsaCrm.Filters.Paginator do
    defstruct [:page_number, :page_size, :total_pages, :entries]
    @moduledoc """
    This module defines the **paginator** struct.
  
    Every time a listing query is done a paginator is created. Every struct has:
  
    - `entries` : The entries of a specific page.
    - `page_number` : The entries page number.
    - `page_size` : The total entries per page.
    - `total_pages` : Total pages for the query.
    """
  
    import Ecto.Query, warn: false
  
    @default_page_size 20
    @default_page_number 1
    @default_total_pages 1
    @default_entries []
    @max_page_size 300
  
    @doc """
    Create a paginator struct with default settings for a specific query.
  
    - `page_size` Is set to 20 by default
    - `page_number` Is set to 1 by default
  
    In other words, if no `page_size` or `page_number` is provided the query will return the first 20 result.
    """
    def new() do
      new(%{
        page_number: @default_page_number,
        page_size: @default_page_size,
        total_pages: 0,
        entries: []
      })
    end
  
    @doc """
    Create a paginator struct with default settings for a specific query.
  
    A paginator map is required.
  
    ```
    iex> new(query, %{page_size: 10, page_number: 3}
    %Api.Filters.Paginator{
      page_number: 3,
      page_size: 10
    }
    ```
  
    This will create a `Api.Filters.Paginator` struct for `n` pages with 10 entries per page, and the `entries` of the 3rd page.
    """
    def new(paginator) do
      % SalsaCrm.Filters.Paginator{
        page_number: get_page_number(Map.get(paginator, :page_number)),
        page_size: get_page_size(Map.get(paginator, :page_size)),
        total_pages: get_total_pages(Map.get(paginator, :total_pages)),
        entries: get_entries(Map.get(paginator, :entries))
      }
    end
    @doc """
    Function to add errors in the paginator element
    """
    def format_errors(paginator) do
      value = []
  
      value =
        if is_integer(paginator.page_number) do
          value
        else
          {:error, message} = paginator.page_number
          [%{key: :page_number, message: message} | value]
        end
  
      value =
        if is_integer(paginator.page_size) do
          value
        else
          {:error, message} = paginator.page_size
          [%{key: :page_size, message: message} | value]
        end
    end
  
    # Function get the page number, or return the default value
    defp get_page_number(page_number) do
      cond do
        is_nil(page_number) ->
          @default_page_number
        page_number == 0 ->
          @default_page_number
        page_number < 0 ->
          {:error, "Value out of range"}
        true ->
          page_number
      end
    end
  
    # Function get the page size, or return the default value
    defp get_page_size(page_size) do
      cond do
        is_nil(page_size) ->
          @default_page_size
        page_size == 0 ->
          @default_page_size
        page_size > @max_page_size or page_size < 0 ->
          {:error, "Value out of range"}
        true ->
          page_size
      end
    end
  
    # Function get the page size, or return the default value
    defp get_total_pages(total_pages) do
      cond do
        is_nil(total_pages) ->
          @default_total_pages
        total_pages == 0 ->
          @default_total_pages
        total_pages < 0 ->
          {:error, "Value out of range"}
        true ->
          total_pages
      end
    end
  
    # Function get the page size, or return the default value
    defp get_entries(entries) do
      cond do
        is_nil(entries) ->
          @default_entries
        entries == [] ->
          @default_entries
        !is_list(entries) ->
          {:error, "Not a list?"}
        true ->
          entries
      end
    end
  end
  