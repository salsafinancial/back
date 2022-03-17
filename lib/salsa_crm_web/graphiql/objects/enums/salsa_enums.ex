defmodule SalsaCrmWeb.Schema.Crm.Enums do
	@moduledoc false
	use Absinthe.Schema.Notation

	@desc "Beneficiary Status in Users."
	enum :beneficiary_status do
		value :OK,                description: "If the beneficiary is active."
		value :XXX1,              description: "If the beneficiary is not active."
		value :XXX2,              description: "If the beneficiary is not active."
	end

	@desc "Account Status."
	enum :account_status do
		value :ENABLE,            description: "The account is active in the system."
		value :DISABLE,           description: "The account is disable in the system."
		value :SUSPENDED,         description: "The account is suspended in the system."
		value :BLOCK,             description: "The account is locked in the system."
		value :FREEZE,            description: "The account is frozen in the system."
	end

	@desc "Transaction Status."
	enum :transaction_status do
		value :PROCESSING,        description: "The creation of the transaction is in process."
		value :DONE,              description: "The transaction has been concluded successfully."
		value :FAILED,            description: "The transaction failed at some point in its execution."
		value :CANCELLED,         description: "The transaction is canceled by the user."
	end

	@desc "Transaction Type."
	enum :transaction_type do
		value :TRANSACTION, 			description: "The transaction is canceled by the user."
		value :DEPOSIT, 					description: "The transaction is canceled by the user."
		value :WITHDRAW, 					description: "The transaction is canceled by the user."
	end

	@desc "Nature of Value."
	enum :value_type do
		value :INCOME
		value :EXPENSE
	end
end
