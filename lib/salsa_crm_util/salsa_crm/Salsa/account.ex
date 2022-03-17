defmodule SalsaCrm.Salsa.Account do
	use Ecto.Schema
	import Ecto.Changeset
	import EctoEnum

	@moduledoc """
		Model for Account. In this module are defined all the Account attributes used in querys and mutations,
		think of these as the columns of the Account table.

		###Columns/Attributes
			* uuid                      - Unique Identifier of the Account in the system
			* id                        - Unique Identifier of the Account
			* organization_id           - Ciiu Name.
			* organizational_unit_id    - Region in which the Ciiu is.
	"""

	# Define the enums used in this model.
	defenum AccountStatus, ["ENABLE", "DISABLE", "SUSPENDED", "BLOCK", "FREEZE"]

	# Define the schema name in DB used for this table, if not given the schema will be public.
	@schema_prefix "salsa"
	# Define the new primary key used to search in DB
	@primary_key {:uuid, Ecto.UUID, autogenerate: true}
	# Define and Phoenix the new structure ID used in the API
	@derive {Phoenix.Param, key: :uuid}
	# Derive the Jason.Encoder so the Program is capable of encode and decode the DB responses.
	@derive Jason.Encoder
	# Time Options to use Time Zone
	@timestamps_opts [type: :utc_datetime]

	schema "accounts" do
		field :id,                        :integer, read_after_writes: true
		field :account_id,            		:string
		field :wallet,            				:string
		field :status,                    AccountStatus
		field :total_amount,              :decimal
		field :future_payments,						:decimal
		field :payments_made,							:decimal
		field :currency_code,             :string
		field :registered_at,             :utc_datetime
		# Embeds
		embeds_one  :dashboard_data,      SalsaCrm.Salsa.DashboardData,   on_replace: :update
		# Timestamps
		timestamps()
	end

	@doc """
		Defines configuration, validations and some operations for the expected parameters 'params'.

		Returns an 'Ecto.Changeset'
	"""
	def changeset(account, attrs) do
		account
		|> cast(attrs, [:account_id, :wallet, :status, :total_amount, :future_payments, :payments_made, :currency_code, :registered_at])
		|> cast_embed(:dashboard_data)
		|> validate_required([:account_id])
	end
end

defmodule SalsaCrm.Salsa.DashboardData do
	use Ecto.Schema
	import Ecto.Changeset

	@moduledoc """
		Embedded Schema that contains control information
	"""

	# Define the new primary key used to search in DB
	@primary_key false
	# Derive the Jason.Encoder so the Program is capable of encode and decode the DB responses.
	@derive Jason.Encoder

	embedded_schema do
		field :incomes,           :decimal
		field :expenses,          :decimal
		# Embeds
		embeds_many :days,  SalsaCrm.Salsa.Days,   on_replace: :delete
		# Timestamps
		timestamps()
	end

	@doc """
		Defines configuration, validations and some operations for the expected parameters 'params'.

		Returns an 'Ecto.Changeset'
	"""
	def changeset(dashboard_data, attrs) do
		dashboard_data
		|> cast(attrs, [:incomes, :expenses])
		|> cast_embed(:days)
	end
end

defmodule SalsaCrm.Salsa.Days do
	use Ecto.Schema
	import Ecto.Changeset

	@moduledoc """
		Embedded Schema that contains control information
	"""

	# Define the new primary key used to search in DB
	@primary_key false
	# Derive the Jason.Encoder so the Program is capable of encode and decode the DB responses.
	@derive Jason.Encoder

	embedded_schema do
		# Embeds
		field :incomes,       	:decimal
		field :payments_made, 	:decimal
		field :future_payments,	:decimal
		field :date,          	:date
	end

	@doc """
		Defines configuration, validations and some operations for the expected parameters 'params'.

		Returns an 'Ecto.Changeset'
	"""
	def changeset(days, attrs) do
		days
		|> cast(attrs, [:incomes, :payments_made, :future_payments, :date])
	end
end
