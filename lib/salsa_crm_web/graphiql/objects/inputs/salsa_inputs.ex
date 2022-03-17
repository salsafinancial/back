defmodule SalsaCrmWeb.Schema.Crm.Input do
	@moduledoc false
	use Absinthe.Schema.Notation

	# ---------------------- Account ------------------------------
	@desc "Filters used to list accounts."
	input_object :account_filter do
		field :account_id,          		:string,            description: "Account number."
		field :status,                  :account_status,    description: "Account status."
	end

	@desc "Filters accepted for the search of an account."
	input_object :account_view do
		field :id,                      :uuid,              description: "Unique identifier of the account."
		field :account_id,          		:string,            description: "Account number."
	end

	@desc "Data that is required for the creation of an account."
	input_object :account_create_input do
		field :account_id,         			non_null(:string),  description: "Unique identifier of the organization in the system."
		field :wallet,  								:string,            description: "Unique identifier of the organizational unit in the system."
	end

	@desc "Entry structure for a search of a account."
	input_object :get_account_info_input do
		field :id,      :string,      description: "The identifier of a account."
	end

	# ---------------------- Transaction ------------------------------
	@desc "Filters used to list transactions."
	input_object :transaction_filter do
		field :account_id,            :string,                      description: "Unique identifier of the account in the system."
		field :source_id,            	:string,                      description: "Unique identifier of the account in the system."
		field :recipient_id,          :string,                    	description: "Unique identifier of the account in the system."
		field :status,                :transaction_status,          description: "Transaction status."
		field :type,                  :transaction_type,            description: "Transaction type."
		field :value_type,            :value_type,                  description: "Transaction value type."
		field :date_start,            :date,                        description: "Search start date."
		field :date_end,              :date,                        description: "Search end date."
	end

	@desc "Filters accepted for the search of a transaction."
	input_object :transaction_view do
		field :id,                    :uuid,                        description: "Unique identifier of the transaction in the system."
		field :code,                  :string,                      description: "Code assigned by the system for each transaction."
	end

	@desc "Data that is required for the creation of a transaction."
	input_object :transaction_create_input do
		field :code,            			non_null(:string)
		field :account_id,            non_null(:string)
		field :source_id,       			non_null(:string)
		field :recipient_id,        	non_null(:string)
		field :amount,         				non_null(:string)
		field :value_type,            :value_type
		field :currency_code,         :string
		field :status,                :transaction_status
		field :type,             			:transaction_type
	end

	@desc "Entry structure for a search of a account."
	input_object :consult_transaction_input do
		field :code,            			non_null(:string),      description: "The identifier of a account."
		field :account_id,            non_null(:string),      description: "The identifier of a account."
		field :source_id,       			non_null(:string),      description: "The identifier of a account."
		field :recipient_id,        	non_null(:string),      description: "The identifier of a account."
		field :amount,         				non_null(:string),      description: "The identifier of a account."
		field :currency_code,         :string,      					description: "The identifier of a account."
		field :apy,										:float,      						description: "The identifier of a account."
		field :period,								:integer,      					description: "The identifier of a account."
		field :next_payment,          :date,      						description: "The identifier of a account."
	end

	 # ---------------------- Objects ------------------------------
	 @desc "Paginator Object"
	 input_object :paginator do
		 field :page_size,         non_null(:integer)
		 field :page_number,       non_null(:integer)
	 end
 
	 @desc "Field."
	 input_object :field do
		 field :key,               :text
		 field :value,             list_of(:any)
	 end
 
	 @desc "Request order"
	 input_object :field_order do
		 field :list_order,        :string
		 field :field,             :string
	 end
end