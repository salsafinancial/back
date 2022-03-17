defmodule SalsaCrm.Salsa.Accounts do
    @moduledoc """
    The Accounts context.
    """
  
    import Ecto.Query, warn: false
    alias SalsaCrm.Repo
  
    alias SalsaCrm.Salsa.Account
  
    @doc """
    Returns the list of accounts.
  
    ## Examples
  
        iex> list_accounts()
        [%Account{}, ...]
  
    """
    def list_accounts do
      Repo.all(Account)
    end
  
    @doc """
    Gets a single account.
  
    Raises `Ecto.NoResultsError` if the Account does not exist.
  
    ## Examples
  
        iex> get_account!(123)
        %Account{}
  
        iex> get_account!(456)
        ** (Ecto.NoResultsError)
  
    """
    def get_account!(id), do: Repo.get!(Account, id)
  
    @doc """
    Creates a account.
  
    ## Examples
  
        iex> create_account(%{field: value})
        {:ok, %Account{}}
  
        iex> create_account(%{field: bad_value})
        {:error, %Ecto.Changeset{}}
  
    """
    def create_account(attrs \\ %{}) do
      %Account{}
      |> Account.changeset(attrs)
      |> Repo.insert()
    end
  
    @doc """
    Updates a account.
  
    ## Examples
  
        iex> update_account(account, %{field: new_value})
        {:ok, %Account{}}
  
        iex> update_account(account, %{field: bad_value})
        {:error, %Ecto.Changeset{}}
  
    """
    def update_account(%Account{} = account, attrs) do
      account
      |> Account.changeset(attrs)
      |> Repo.update()
    end
  
    @doc """
    Deletes a account.
  
    ## Examples
  
        iex> delete_account(account)
        {:ok, %Account{}}
  
        iex> delete_account(account)
        {:error, %Ecto.Changeset{}}
  
    """
    def delete_account(%Account{} = account) do
      Repo.delete(account)
    end
  
    @doc """
    Returns an `%Ecto.Changeset{}` for tracking account changes.
  
    ## Examples
  
        iex> change_account(account)
        %Ecto.Changeset{source: %Account{}}
  
    """
    def change_account(%Account{} = account) do
      Account.changeset(account, %{})
    end
  
    def list_accounts_filters(filters, paginator \\ %{page_size: 10, page_number: 1}, order \\ %{list_order: :desc, field: :inserted_at}) do
      accounts =
        SalsaCrm.Filters.Event.new(%{filter: filters}, Account, true, paginator)
          |> SalsaCrm.Filters.Manager.notify_all(order)
    end
  
    def view_account(filters) do
      account =
        SalsaCrm.Filters.Event.new(%{filter: filters}, Account, false, %{pase_size: 1, page_number: 1})
          |> SalsaCrm.Filters.Manager.notify_all("no order")
    end
  
    # alias MsCrm.NaaS.AccountHist
  
    # @doc """
    # Returns the list of accounts_historical.
  
    # ## Examples
  
    #     iex> list_accounts_historical()
    #     [%Account_Hist{}, ...]
  
    # """
    # def list_account_historical do
    #   Repo.all(AccountHist)
    # end
  
    # @doc """
    # Gets a single account_hist.
  
    # Raises `Ecto.NoResultsError` if the Account_hist does not exist.
  
    # ## Examples
  
    #     iex> get_account_hist!(123)
    #     %Account_Hist{}
  
    #     iex> get_account_hist!(456)
    #     ** (Ecto.NoResultsError)
  
    # """
    # def get_account_hist!(id), do: Repo.get!(AccountHist, id)
  
    # @doc """
    # Creates a account_hist.
  
    # ## Examples
  
    #     iex> create_account_hist(%{field: value})
    #     {:ok, %Account_Hist{}}
  
    #     iex> create_account_hist(%{field: bad_value})
    #     {:error, %Ecto.Changeset{}}
  
    # """
    # def create_account_hist(attrs \\ %{}) do
    #   %AccountHist{}
    #   |> AccountHist.changeset(attrs)
    #   |> Repo.insert()
    # end
  
    # @doc """
    # Updates a account_hist.
  
    # ## Examples
  
    #     iex> update_account_hist(account_hist, %{field: new_value})
    #     {:ok, %Account_Hist{}}
  
    #     iex> update_account_hist(account_hist, %{field: bad_value})
    #     {:error, %Ecto.Changeset{}}
  
    # """
    # def update_account_hist(%AccountHist{} = account_hist, attrs) do
    #   account_hist
    #   |> AccountHist.changeset(attrs)
    #   |> Repo.update()
    # end
  
    # @doc """
    # Deletes a account_hist.
  
    # ## Examples
  
    #     iex> delete_account_hist(account_hist)
    #     {:ok, %Account_Hist{}}
  
    #     iex> delete_account_hist(account_hist)
    #     {:error, %Ecto.Changeset{}}
  
    # """
    # def delete_account_hist(%AccountHist{} = account_hist) do
    #   Repo.delete(account_hist)
    # end
  
    # @doc """
    # Returns an `%Ecto.Changeset{}` for tracking account_hist changes.
  
    # ## Examples
  
    #     iex> change_account_hist(account_hist)
    #     %Ecto.Changeset{source: %Account_Hist{}}
  
    # """
    # def change_account_hist(%AccountHist{} = account_hist) do
    #   AccountHist.changeset(account_hist, %{})
    # end
  end
  