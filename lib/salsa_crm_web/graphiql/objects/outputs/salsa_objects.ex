defmodule SalsaCrmWeb.Schema.Crm.Output do
	@moduledoc false
	use Absinthe.Schema.Notation

	@desc "Structure with account data."
	object :account_info do
		field :lamports,          :integer,          description: "Amount to be requested in the credit."
		field :rent_epoch,    		:integer,          description: "Place in queue in case of waiting to receive credit."
	end

	# ---------------------- Account ------------------------------
	@desc "Account data."
	object :account do
	  field :id,               		:uuid,           	description: "Unique identifier of the account in the system."
	  field :account_id,         	:string,          description: "Unique identifier of the wallet."
    field :wallet,         	    :string,          description: "Unique identifier of the wallet."
	  field :status,  						:account_status,  description: "Unique identifier of the organizational unit in the system."
	  field :total_amount,       	:string,          description: "Unique identifier of the order in the system."
	  field :future_payments,     :string,          description: "Unique identifier of the product purchased in the system."
	  field :payments_made,       :string,          description: "Unique identifier of the beneficiary in the system."
	  field :currency_code,       :string,          description: "Account number."
	  field :registered_at,       :datetime,        description: "Account name."
	  field :dashboard_data,      :map,            	description: "Data pertinent to the Dashboard of the account."
	end

	@desc "Output data from an account list."
  object :accounts do
    field :accounts,          list_of(:account),                description: "An account list."
    field :page_info,         :page_info,                       description: "Page information."
  end

  @desc "Output data from an account mutation."
  object :account_data do
    field :account,           :account,                         description: "Account data."
    field :error,             :error,                           description: "Error scheme that is sent in the event that a query or mutation fails."
  end

	# ---------------------- Transaction ------------------------------
  @desc "Transaction data."
  object :transaction do
    field :id,                    :uuid,                        description: "Unique identifier of the transaction in the system."
    field :code,                  :string,                      description: "Code assigned by the system for each transaction."
    field :type,                  :transaction_type,            description: "Transaction type."
		field :account_id,            :string,                      description: "Unique identifier of the account in the system."
    field :source_id,             :string,                      description: "Unique identifier of the account in the system."
    field :recipient_id,          :string,                      description: "Unique identifier of the account in the system."
		field :amount,                :string,                      description: "Amount of money with which the transfer is recorded."
		field :value_type,            :value_type,                  description: "Nature of amount of money with which the transfer is recorded."
		field :currency_code,         :string,                      description: "Currency in which the amounts are handled."
    field :apy,                   :float,                       description: "Currency in which the amounts are handled."
    field :rewards,               :string,                      description: "Currency in which the amounts are handled."
		field :date,           				:datetime,                    description: "Date on which the transaction occurs. With timezone."
		field :period,         				:integer,                     description: "Approval code assigned by the system for each transaction."
    field :next_payment,          :date,                        description: "Cut-off date of each collection."
		field :date_payment,          :datetime,                    description: "Date on which the transaction occurs. With timezone."
    field :status,                :transaction_status,          description: "Transaction status."
		field :notes,                 :string,                      description: "Additional notes by the beneficiary."
		field :description_transfer,  :string,                      description: "Description of the transfer that is made."
		field :misc_data,             :map,       									description: "Additional transaction data."
  end

	@desc "Output data from a transaction list."
  object :transactions do
    field :transactions,      list_of(:transaction),            description: "A transaction list."
    field :page_info,         :page_info,                       description: "Page information."
  end

  @desc "Output data from an transaction mutation."
  object :transaction_data do
    field :transaction,       :transaction,                     description: "Transaction data."
    field :error,             :error,                           description: "Error scheme that is sent in the event that a query or mutation fails."
  end

	@desc "Output data from a transaction list."
  object :consult_transaction_output do
    field :status,      			:string,           		 						description: "A transaction list."
  end

	# ---------------------- Public ------------------------------
  # @desc "App version."
  # object :version do
  #   field :version,       :string,    description: "App version."
  # end

  @desc "Información referente a la paginación"
  object :page_info do
    field :page_number,   :integer
    field :page_size,     :integer
    field :total_pages,   :integer
    field :total_entries, :integer
  end

  @desc "Error Message"
  object :error do
    field :error,     :string,    description: "String that contains the Error Message"
    field :id,        :string,    description: "Error code defined under a standard."
    field :type,      :string,    description: "General type of error (eg InputError, formError, etc.)."
    field :subType,   :string,    description: "An error subtype that specifies the general type. This will be defined by the micro service, application or web portal as the case may be."
    field :message,   :string,    description: "String that contains the Error Message."
    field :title,     :string,    description: "A title or name of the error itself."
    field :helpText,  :string,    description: "A help text that can be used by whoever receives the error to understand the cause of it and how to correct it or, in the worst case, notify the help desk. In general, this should be a url to which the user who received the error can go to find useful information about the error."
    field :language,  :string,    description: "Language in which the error is returned. By default all errors are returned in English (en-US)."
  end
end