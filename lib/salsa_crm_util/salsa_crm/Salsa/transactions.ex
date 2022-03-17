defmodule SalsaCrm.Salsa.Transactions do
	@moduledoc """
	The Transactions context.
	"""

	import Ecto.Query, warn: false
	alias SalsaCrm.Repo

	alias SalsaCrm.Salsa.Transaction

	@doc """
	Returns the list of transactions.

	## Examples

			iex> list_transactions()
			[%Transaction{}, ...]

	"""
	def list_transactions do
		Repo.all(Transaction)
	end

	@doc """
	Gets a single transaction.

	Raises `Ecto.NoResultsError` if the Transaction does not exist.

	## Examples

			iex> get_transaction!(123)
			%Transaction{}

			iex> get_transaction!(456)
			** (Ecto.NoResultsError)

	"""
	def get_transaction!(id), do: Repo.get!(Transaction, id)

	@doc """
	Creates a transaction.

	## Examples

			iex> create_transaction(%{field: value})
			{:ok, %Transaction{}}

			iex> create_transaction(%{field: bad_value})
			{:error, %Ecto.Changeset{}}

	"""
	def create_transaction(attrs \\ %{}) do
		%Transaction{}
		|> Transaction.changeset(attrs)
		|> IO.inspect()
		|> Repo.insert()
	end

	@doc """
	Updates a transaction.

	## Examples

			iex> update_transaction(transaction, %{field: new_value})
			{:ok, %Transaction{}}

			iex> update_transaction(transaction, %{field: bad_value})
			{:error, %Ecto.Changeset{}}

	"""
	def update_transaction(%Transaction{} = transaction, attrs) do
		transaction
		|> Transaction.changeset(attrs)
		|> Repo.update()
	end

	@doc """
	Deletes a transaction.

	## Examples

			iex> delete_transaction(transaction)
			{:ok, %Transaction{}}

			iex> delete_transaction(transaction)
			{:error, %Ecto.Changeset{}}

	"""
	def delete_transaction(%Transaction{} = transaction) do
		Repo.delete(transaction)
	end

	@doc """
	Returns an `%Ecto.Changeset{}` for tracking transaction changes.

	## Examples

			iex> change_transaction(transaction)
			%Ecto.Changeset{source: %Transaction{}}

	"""
	def change_transaction(%Transaction{} = transaction) do
		Transaction.changeset(transaction, %{})
	end

	def list_transactions_filters(filters, paginator \\ %{page_size: 10, page_number: 1}, order \\ %{list_order: :desc, field: :inserted_at}) do
		transactions =
			SalsaCrm.Filters.Event.new(%{filter: filters}, Transaction, true, paginator)
			|> SalsaCrm.Filters.Manager.notify_all(order)
	end

	def view_transaction(filters) do
		transaction =
			SalsaCrm.Filters.Event.new(%{filter: filters}, Transaction, false, %{pase_size: 1, page_number: 1})
			|> SalsaCrm.Filters.Manager.notify_all("no order")
	end
end