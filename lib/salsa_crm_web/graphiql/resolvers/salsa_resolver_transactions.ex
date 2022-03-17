defmodule SalsaCrmWeb.Schema.Crm.Resolvers.Transactions do
	@moduledoc """
	This is the NaaS Resolver. All the behaviour of the Financial Operations should be called through this module.

	In general the functions defined in this module return a tuple. {:ok , %Struct} for successful operations and
	{:ok, %{error: %{error: "Message"}}} for unsucessful operations
	"""

	alias SalsaCrm.Salsa.Account
	alias SalsaCrm.Salsa.Accounts
	alias SalsaCrmWeb.Schema.Crm.Resolvers.Accounts, as: AccountsResolver
	alias SalsaCrm.Salsa.Transaction
	alias SalsaCrm.Salsa.Transactions
	alias SalsaCrm.CommonFunctions
	alias Numbers, as: N

	# ---------------------------------- QUERIES --------------------------------------------

	@doc """
		Giving some parameters return an object of type 'transaction'
		##Examples
		iex> view_transaction(_,%{input: args}},_)
		{:ok, %{transaction:  %{...}}}
		iex> view_transaction(_, %{input: %{}}, _)
		{:ok, %{error: "No Filters Applied"}}}
		iex> view_transaction(_, %{input: args}, _)
		{:ok, %{error: "The Search could not be completed"}}}
	"""
	def transaction(_conn?, %{input: filters}, _absinthe_resolution) do
		if filters==%{} do
			{:ok, %{error: %{error: "No Filters Applied"}}}
		else
			result = Transactions.view_transaction(filters)
			if is_nil(result) do
				{:ok, nil}
			else
				{:ok, %{
					id: result.uuid,
					code: result.code,
					type: result.type,
					account_id: result.account_id,
					source_id: result.source_id,
					recipient_id: result.recipient_id,
					amount: result.amount,
					value_type: result.value_type,
					currency_code: result.currency_code,
					apy: result.apy,
					rewards: result.rewards,
					date: result.date,
					period: result.period,
					next_payment: result.next_payment,
					date_payment: result.date_payment,
					status: result.status,
					notes: result.notes,
					description_transfer: result.description_transfer,
					misc_data: result.misc_data
				}}
			end
		end
	end
  
	@doc """
		Given some filters and a paginator object returns the 'transactions' that fit the filters and the pagination parameters
		##Examples
		iex> list_transactions(_,%{input: filters, paginator: %{pageSize: 5, pageNumber: 2}}, _)
		{:ok, %{entries: %{...}, paginator_output: %{total_entries: n, page: 2, pase_size: 5}}}
		iex> list_transactions(_%{input: %{}, paginator: %{pageSize: 5, pageNumber: 2}}, _)
		{:ok, %{error: "No Filters Applied}}
	"""
	def transactions(_conn?, %{filter: filters, paginator: paginator, order_by: field_order}, _absinthe_resolution) do
		if filters==%{} do
			{:ok, %{error: %{error: "No Filters Applied"}}}
		else
			with {:ok, result} <- Transactions.list_transactions_filters(filters, paginator, field_order) do
				now = DateTime.add(DateTime.utc_now(), -18_000, :second)
				result = Map.replace(result, :entries, Enum.map(result.entries, fn x ->
					hours = DateTime.diff(now, x.date)
					|> Decimal.div(60)
					|> Decimal.div(60)
					|> Decimal.round(0, :floor)

					apy = if x.apy == 10, do: 0.0079, else: 0.01531
					reward = Decimal.div(Decimal.from_float(apy), 720)
					|> Decimal.mult(hours)
					|> Decimal.mult(x.amount)

					Map.replace(x, :id, x.uuid)
					Map.replace(x, :rewards, reward)
				end))
				{:ok, %{
					transactions: result.entries,
					page_info: %{
						page_number: result.page_number,
						page_size: result.page_size,
						total_entries: result.total_entries,
						total_pages: result.total_pages
					}
				}}
			else
				{:error, error} -> {:ok, %{error: %{error: error}}}
				_ -> {:ok, %{error: %{error: "The Search could not be completed"}}}
			end
		end
	end

	# ------------------------------- MUTATIONS ------------------------------------------

		@doc """
		Create a 'transaction' into the data base with the args passed.
		## Examples
		iex> create_transaction(_,%{input: %{...}},_)
		{:ok, %{...}}

		iex> create_transaction(_,%{input: %{...}},_)
		{:ok, %{error: "No se pudo crear el registro"}}
	"""
	def create_transaction(_conn?, %{transaction_create_input: args}, _absinthe_resolution) do
		CommonFunctions.check_partition("salsa", "transactions", args.currency_code)
		args = put_in(args, [:type], "DEPOSIT")
		args = put_in(args, [:value_type], "EXPENSE")
		args = put_in(args, [:rewards], "0.00")
		args = put_in(args, [:date], DateTime.add(DateTime.utc_now(), -18_000, :second))
		args = put_in(args, [:status], "DONE")
		with {:ok, data} <- Transactions.create_transaction(args) do
			data = Map.from_struct(data)
			data = put_in(data, [:id], data.uuid)
			{:ok, %{transaction: data}}
		else
			{:error, %Ecto.Changeset{}} -> {:error, "Changeset Error"}
			_ -> {:error, "The transaction could not be created"}
		end
	end

	@doc """
		Update a 'transaction' in to the data base with the args passsed.
		## Examples
		iex> update_transaction(_, %{input: %{...}},_)
		{:ok, %{...}}

		iex> update_transaction(_,%{input: %{...}}_)
		{:ok, %{error: "No se pudo actualizar el registro"}}

		iex> update_transaction(_,%{input: %{...}},_)
		{:ok, %{error: "No se encontro el registro"}}
	"""
	def update_transaction(_conn?, %{id: id, transaction_update_input: args}, _absinthe_resolution) do
		with %Transaction{} = data <- Transactions.get_transaction!(id) do
			with {:ok, updated_data} <- Transactions.update_transaction(data, args) do
				updated_data = Map.from_struct(updated_data)
				updated_data = put_in(updated_data, [:id], updated_data.uuid)
				{:ok, %{transaction: updated_data}}
			else
				{:error, %Ecto.Changeset{}} -> {:error, "Changeset Error"}
				_ -> {:error, "Could not update the transaction"}
			end
		else
			_ -> {:error, "The Search could not be completed"}
		end
	end

	def add_notes_transaction(_conn?, %{id: id, notes: notes}, _absinthe_resolution) do
		with %Transaction{} = data <- Transactions.get_transaction!(id) do
			with {:ok, updated_data} <- Transactions.update_transaction(data, %{notes: notes}) do
				updated_data = Map.from_struct(updated_data)
				updated_data = put_in(updated_data, [:id], updated_data.uuid)
				{:ok, %{transaction: updated_data}}
			else
				{:error, %Ecto.Changeset{}} -> {:ok, %{error: %{error: "Changeset Error"}}}
				_ -> {:ok, %{error: %{error: "Could not update the record"}}}
			end
		else
			_ -> {:ok, %{error: "The Search could not be completed"}}
		end
	end

	def consult_transaction(_conn?, %{input: args}, _absinthe_resolution) do
		case Accounts.view_account(account_id: args.account_id) do
			%Account{} = data ->
				{:ok, data}
			_ -> 
				account_create_input = %{
					account_id: args.account_id,
      		wallet: "Phantom"
				}
				AccountsResolver.create_account(nil, %{account_create_input: account_create_input}, nil)
		end

		apy = if args.apy == 10, do: "0.0957", else: "0.18374"
		apy = apy |> Decimal.new() |> Decimal.div(12) |> Decimal.add(1) |> N.pow(args.period) |> Decimal.sub(1) |> IO.inspect(label: "apy calculado")

		future_payment = Decimal.mult(args.amount, apy) |> Decimal.round(2)

		salsa_account = Accounts.view_account(account_id: args.recipient_id)
		salsa_account_update_input = %{
			total_amount: Decimal.add(salsa_account.total_amount, args.amount),
			future_payments: Decimal.add(salsa_account.future_payments, future_payment),
			dashboard_data: %{
				incomes: Decimal.add(salsa_account.dashboard_data.incomes, args.amount),
				days: AccountsResolver.add_day_dashboard(salsa_account.dashboard_data.days, args.amount, Decimal.new("0.00"), Decimal.new("0.00"), nil)
			}
		}

		case Accounts.update_account(salsa_account, salsa_account_update_input) do
			{:ok, account} -> {:ok, account}
			{:error, _error} -> {:error, "Source Account Changeset Error"}
		end

		account = Accounts.view_account(account_id: args.account_id)		
		account_update_input = %{
			total_amount: Decimal.add(account.total_amount, args.amount),
			future_payments: Decimal.add(account.future_payments, future_payment),
			dashboard_data: %{
				expenses: Decimal.add(account.dashboard_data.expenses, args.amount),
				days: AccountsResolver.add_day_dashboard(account.dashboard_data.days, Decimal.new("0.00"), args.amount, Decimal.new("0.00"), nil)
			}
		}

		case Accounts.update_account(account, account_update_input) do
			{:ok, account} -> {:ok, account}
			{:error, _error} -> {:error, "Source Account Changeset Error"}
		end

		salsa_account = Accounts.view_account(account_id: args.recipient_id)
		account = Accounts.view_account(account_id: args.account_id)
		account_update_future1_input = %{dashboard_data: %{days: AccountsResolver.add_day_dashboard(salsa_account.dashboard_data.days, Decimal.new("0.00"), Decimal.new("0.00"), future_payment, args.next_payment)}}
		Accounts.update_account(salsa_account, account_update_future1_input)
		account_update_future2_input = %{dashboard_data: %{days: AccountsResolver.add_day_dashboard(account.dashboard_data.days, Decimal.new("0.00"), Decimal.new("0.00"), future_payment, args.next_payment)}}
		Accounts.update_account(account, account_update_future2_input)

		case create_transaction(nil, %{transaction_create_input: args}, nil) do
			{:ok, %{transaction: data}} ->
				{:ok, %{status: "Transaction confirmed"}}
			{:error, error} -> 
				{:ok, %{error: %{error: "Could not create the transaction"}}}
		end
	end
end
  