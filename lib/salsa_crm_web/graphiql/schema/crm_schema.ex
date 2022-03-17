defmodule SalsaCrmWeb.Schema.Crm do
	@moduledoc false
	use Absinthe.Schema

	# Import Processes Objects
	import_types __MODULE__.Input
	import_types __MODULE__.Output
	import_types __MODULE__.Enums
	import_types __MODULE__.Types

	alias SalsaCrmWeb.Schema.Crm.Resolvers.Accounts
	alias SalsaCrmWeb.Schema.Crm.Resolvers.Transactions

	query do
		# ------------------------------- Accounts ------------------------------------------
		@desc "Query to consult a list of accounts according to the filters entered."
		field :accounts, :accounts do
		  arg :filter,                non_null(:account_filter),  description: "Filters to consult the accounts."
		  arg :paginator,             non_null(:paginator),       description: "Paginator used to perform the search."
		  arg :order_by,              non_null(:field_order),     description: "Field by which the accounts are sorted."
		  resolve &Accounts.accounts/3
		end
	
		@desc "Query to consult information from an account according to its ID or account number."
		field :account, :account do
		  arg :input,                 non_null(:account_view),    description: "Filters accepted for the search of an account."
		  resolve &Accounts.account/3
		end

		# ------------------------------- Transactions ------------------------------------------
    @desc "Query to consult a list of transactions according to the filters entered."
    field :transactions, :transactions do
      arg :filter,                non_null(:transaction_filter),  description: "Filters to consult the transactions."
      arg :paginator,             non_null(:paginator),           description: "Paginator used to perform the search."
      arg :order_by,              non_null(:field_order),         description: "Field by which the transactions are sorted."
      resolve &Transactions.transactions/3
    end

    @desc "Query to consult information from an transaction according to its ID."
    field :transaction, :transaction do
      arg :input,                 non_null(:transaction_view),    description: "Filters accepted for the search of a transaction."
      resolve &Transactions.transaction/3
    end

		@desc "Query to consult information from an transaction according to its ID."
    field :consult_transaction, 	:consult_transaction_output do
      arg :input,                 non_null(:consult_transaction_input),    description: "Filters accepted for the search of a transaction."
      resolve &Transactions.consult_transaction/3
    end
	end

	mutation do
		# ------------------------------- Accounts --------------------------------------------
		@desc "Mutation for the creation of an account."
		field :create_account,    :account_data do
			arg :account_create_input,    non_null(:account_create_input),  description: "Account information."
			resolve &Accounts.create_account/3
		end

		# @desc "Mutation for updating an account."
		# field :update_account,    :account_data do
		# 	arg :id,                      non_null(:uuid),                  description: "Unique identifier of the account."    
		# 	arg :account_update_input,    non_null(:account_update_input),  description: "Account information."
		# 	resolve &Accounts.update_account/3
		# end

		# ------------------------------- Transactions --------------------------------------------
    @desc "Mutation for the creation of a transaction."
    field :create_transaction,    :transaction_data do
      arg :transaction_create_input,    non_null(:transaction_create_input),  description: "Transaction information."
      resolve &Resolvers.create_transaction/3
    end

    # @desc "Mutation for updating a transaction."
    # field :update_transaction,    :transaction_data do
    #   arg :id,                        non_null(:uuid),                      description: "Unique identifier of the transaction."
    #   arg :transaction_update_input,  non_null(:transaction_update_input),  description: "Transaction information."
    #   resolve &Resolvers.update_transaction/3
    # end

    @desc "Mutation for updating a transaction."
    field :add_notes_transaction,    :transaction_data do
      arg :id,                        non_null(:uuid),              description: "Unique identifier of the transaction."
      arg :notes,                     non_null(:string),            description: "Notes by the user."
      resolve &Resolvers.add_notes_transaction/3
    end
	end
end