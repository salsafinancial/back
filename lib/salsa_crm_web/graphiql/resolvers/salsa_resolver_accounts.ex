defmodule SalsaCrmWeb.Schema.Crm.Resolvers.Accounts do
	@moduledoc """
	This is the NaaS Resolver. All the behaviour of the Financial Operations should be called through this module.

	In general the functions defined in this module return a tuple. {:ok , %Struct} for successful operations and
	{:ok, %{error: %{error: "Message"}}} for unsucessful operations
	"""

	alias SalsaCrm.Salsa.Account
	alias SalsaCrm.Salsa.Accounts
	alias SalsaCrm.Salsa.Transaction
	alias SalsaCrm.Salsa.Transactions
	alias SalsaCrm.CommonFunctions

	# ---------------------------------- QUERIES ---------------------------------------------
	@doc """
		Giving some parameters return an object of type 'account'
		##Examples
		iex> view_account(_,%{input: args}},_)
		{:ok, %{account:  %{...}}}
		iex> view_account(_, %{input: %{}}, _)
		{:ok, %{error: "No Filters Applied"}}}
		iex> view_account(_, %{input: args}, _)
		{:ok, %{error: "The Search could not be completed"}}}
	"""
	def account(_conn?, %{input: filters}, _absinthe_resolution) do
		if filters == %{} do
			{:ok, %{error: %{error: "No Filters Applied"}}}
		else
			result = Accounts.view_account(filters)
			if is_nil(result) do
				{:ok, nil}
			else
				{:ok, %{
					id: result.uuid,
					account_id: result.account_id,
					wallet: result.wallet,
					status: result.status,
					total_amount: result.total_amount,
					future_payments: result.future_payments,
					payments_made: result.payments_made,
					currency_code: result.currency_code,
					registered_at: result.registered_at,
					dashboard_data: result.dashboard_data
				}}
			end
		end
	end
  
	@doc """
		Given some filters and a paginator object returns the 'accounts' that fit the filters and the pagination parameters
		##Examples
		iex> list_accounts(_,%{input: filters, paginator: %{pageSize: 5, pageNumber: 2}}, _)
		{:ok, %{entries: %{...}, paginator_output: %{total_entries: n, page: 2, pase_size: 5}}}
		iex> list_accounts(_%{input: %{}, paginator: %{pageSize: 5, pageNumber: 2}}, _)
		{:ok, %{error: "No Filters Applied}}
	"""
	def accounts(_conn?, %{filter: filters, paginator: paginator, order_by: field_order}, _absinthe_resolution) do
		if filters == %{} do
			{:ok, %{error: %{error: "No Filters Applied"}}}
		else
			case Accounts.list_accounts_filters(filters, paginator, field_order) do
				{:ok, result} ->
					result = Map.replace(result, :entries, Enum.map(result.entries, fn x -> Map.replace(x, :id, x.uuid) end))
					{:ok, %{
						accounts: result.entries,
						page_info: %{
							page_number: result.page_number,
							page_size: result.page_size,
							total_entries: result.total_entries,
							total_pages: result.total_pages
						}
					}}
				{:error, error} -> {:ok, %{error: %{error: error}}}
				_ -> {:ok, %{error: %{error: "The Search could not be completed"}}}
			end
		end
	end
  
	# ------------------------------- MUTATIONS ------------------------------------------

	@doc """
		Create a 'account' into the data base with the args passed.
		## Examples
		iex> create_account(_,%{input: %{...}},_)
		{:ok, %{...}}

		iex> create_account(_,%{input: %{...}},_)
		{:ok, %{error: "No se pudo crear el registro"}}
	"""
	def create_account(_conn?, %{account_create_input:  args}, _absinthe_resolution) do
		CommonFunctions.check_partition("salsa", "accounts", args.wallet)
		args = put_in(args, [:status], "ENABLE")
		args = put_in(args, [:total_amount], "0.00")
		args = put_in(args, [:future_payments], "0.00")
		args = put_in(args, [:payments_made], "0.00")
		args = put_in(args, [:currency_code], "USDC")
		args = put_in(args, [:registered_at], DateTime.add(DateTime.utc_now(), -18_000, :second))
		args = put_in(args, [:dashboard_data], %{})
		args = put_in(args, [:dashboard_data, :incomes], "0.00")
		args = put_in(args, [:dashboard_data, :expenses], "0.00")
		args = put_in(args, [:dashboard_data, :days], [
			%{date: DateTime.to_date(DateTime.add(DateTime.utc_now(), -18_000, :second)), incomes: "0.00", payments_made: "0.00", future_payments: "0.00"}
		])
		case Accounts.create_account(args) do
			{:ok, data} ->
				data = Map.from_struct(data)
				data = put_in(data, [:id], data.uuid)
				{:ok, %{account: data}}
			{:error, %Ecto.Changeset{}} -> {:error, "Changeset Error"}
			_ -> {:error, "The account could not be created"}
		end
	end

	@doc """
		Update a 'account' in to the data base with the args passsed.
		## Examples
		iex> update_account(_, %{input: %{...}},_)
		{:ok, %{...}}

		iex> update_account(_,%{input: %{...}}_)
		{:ok, %{error: "No se pudo actualizar el registro"}}

		iex> update_account(_,%{input: %{...}},_)
		{:ok, %{error: "No se encontro el registro"}}
	"""
	def update_account(_conn?, %{id: id, account_update_input: args}, _absinthe_resolution) do
		case Accounts.view_account(id: id) do
			%Account{} = data ->
				case Accounts.update_account(data, args) do
					{:ok, updated_data} ->
						updated_data = Map.from_struct(updated_data)
						updated_data = put_in(updated_data, [:id], updated_data.uuid)
						{:ok, %{account: updated_data}}
					{:error, %Ecto.Changeset{}} -> {:error, "Changeset Error"}
					_ -> {:error, "Could not update the account"}
				end
			_ -> {:error, "The Search could not be completed"}
		end
	end

	def add_day_dashboard(days, incomes, payments_made, future_payments, date) do
		IO.inspect(days, label: "days antes de añadir día")
		days = Enum.map(days, fn x -> Map.from_struct(x) end)
		today = if is_nil(date), do: DateTime.to_date(DateTime.add(DateTime.utc_now(), -18_000, :second)), else: date

		if (Enum.any?(days, fn x -> x.date == today end)) == true do
			Enum.map(days, fn x ->
				if x.date == today do
					x
					|> Map.put(:incomes, Decimal.add(x.incomes, incomes))
					|> Map.put(:payments_made, Decimal.add(x.payments_made, payments_made))
					|> Map.put(:future_payments, Decimal.add(x.future_payments, future_payments))
				else
					x
				end
			end)
		else
			new_day = %{}
			|> Map.put(:incomes, incomes)
			|> Map.put(:payments_made, payments_made)
			|> Map.put(:future_payments, future_payments)
			|> Map.put(:date, today)

			[new_day | days]
		end
	end
end
  