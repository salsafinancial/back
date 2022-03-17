defmodule SalsaCrm.Salsa.Transaction do
	use Ecto.Schema
	import Ecto.Changeset
	import EctoEnum

	defenum TransactionStatus, ["PROCESSING", "DONE", "FAILED", "CANCELLED"]
	defenum TransactionType, ["TRANSACTION", "DEPOSIT", "WITHDRAW"]
	defenum ValueType, ["INCOME", "EXPENSE"]

	@schema_prefix "salsa"
	# Define the new primary key used to search in DB
	@primary_key {:uuid, Ecto.UUID, autogenerate: true}
	# Define and Phoenix the new structure ID used in the API
	@derive {Phoenix.Param, key:  :uuid}
	# Derive the Jason.Encoder so the Program is capable of encode and decode the DB responses.
	@derive Jason.Encoder
	# Time Options to use Time Zone
	@timestamps_opts [type: :utc_datetime_usec]

	schema "transactions" do
		field :id,                    :integer, read_after_writes: true
		field :code,                  :string
		field :type,                  TransactionType
		field :account_id,						:string
		field :source_id,							:string
		field :recipient_id,					:string
		field :amount,                :decimal
		field :value_type,            ValueType
		field :currency_code,         :string
		field :apy,										:float
		field :rewards,								:decimal
		field :date,           				:utc_datetime_usec
		field :period,								:integer
		field :next_payment,          :date
		field :date_payment,					:utc_datetime_usec
		field :status,                TransactionStatus
		field :notes,                 :string
		field :description_transfer,  :string
		field :misc_data,             :map
		
		# Timestamps  
		timestamps()
	end

	@doc """
		Defines configuration, validations and some operations for the expected parameters 'params'.

		Returns an 'Ecto.Changeset'
	"""
	def changeset(transaction, attrs) do
		transaction
		|> cast(attrs, [:code, :type, :account_id, :source_id, :recipient_id, :amount, :value_type, :currency_code, :apy, :rewards, :date, :period, :next_payment, :date_payment, :status, :notes, :description_transfer, :misc_data])
		|> validate_required([:account_id, :value_type, :type, :source_id, :recipient_id])
	end
end
