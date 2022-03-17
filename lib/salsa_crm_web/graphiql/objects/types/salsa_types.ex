defmodule SalsaCrmWeb.Schema.Crm.Types do
	@moduledoc false
		use Absinthe.Schema.Notation
		alias Absinthe.Blueprint.Input

		# -------------------------------- EMAIL TYPE ----------------

	scalar :email, name: "email" do
		description("""
		The `email` scalar type represents an email address.
		""")
		# Input format, json to elixir
		parse(&decode_email/1)
		# Output format, elixir to json
		serialize(&encode_email/1)
	end

	# Parsing for a string data with email format
	defp decode_email(%Input.String{value: value}) do
			# Example function to validate a email using regular expresions
	Application.get_env(:users_api, :resources)
	|> Map.fetch!(Regex)
	|> Map.fetch!(:email)
	|> Regex.run(value)
		|> case do
			nil -> :error
			[value] -> {:ok, value}
		end
	end

	# Parsing for the null type
	defp decode_email(%Input.Null{}), do: :error

	# Default parsing
	defp decode_email(_), do: :error

	# Function to serialize
	defp encode_email(value), do: value

	# -------------------------------- ANY TYPE ----------------

	scalar :any, name: "any" do
		description("""
		The 'any' scalar type represents any type of data.
		""")
		# Input format
		parse(&decode_any/1)
		# Output format
		serialize(&encode_any/1)
	end

	# Validate input with Null type
	@spec decode_any(Absinthe.Blueprint.Input.Null.t()) :: :error

	# Function to parse
	defp decode_any(%Absinthe.Blueprint.Input.Null{}), do: :error

	defp decode_any(value), do: value

	# Function to Serialize
	defp encode_any(value), do: value

	# -------------------------------- TEXT TYPE ----------------

	scalar :text, name: "text" do
		description("""
		The `text` scalar type represents a string with at least 1 chars
		""")
		# Input format, json to elixir
		parse(&decode_text/1)
		# Output format, elixir to json
		serialize(&encode_text/1)
	end

	# Validate input with String type
	@spec decode_text(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error

	# Validate input with Null type
	@spec decode_text(Absinthe.Blueprint.Input.Null.t()) :: :error

	# Function to parse a string data from elixir to json
	defp decode_text(%Absinthe.Blueprint.Input.String{value: value}) do
		if String.length(value) > 0, do: {:ok, value}, else: :error
	end

	# Function to parse a null type
	defp decode_text(%Absinthe.Blueprint.Input.Null{}), do: :error

	# Function to parse data from elixir to json
	defp decode_text(_), do: :error

	# Function to serialize
	defp encode_text(value), do: value

	# -------------------------------- CITEXT TYPE ----------------

	scalar :citext, name: "citext" do
		description("""
		The `citext` scalar type represents a string with at least 2 chars
		""")
		# Input format, json to elixir
		parse(&decode_citext/1)
		# Output format, elixir to json
		serialize(&encode_citext/1)
	end

	# Validate input with String type
	@spec decode_citext(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error

	# Validate input with Null type
	@spec decode_citext(Absinthe.Blueprint.Input.Null.t()) :: :error

	# Function to parse a string data from elixir to json
	defp decode_citext(%Absinthe.Blueprint.Input.String{value: value}) do
		if String.length(value) > 1, do: {:ok, value}, else: :error
	end

	# Function to parse a null type
	defp decode_citext(%Absinthe.Blueprint.Input.Null{}), do: :error

	# Function to parse data from elixir to json
	defp decode_citext(_), do: :error

	# Function to serialize
	defp encode_citext(value), do: String.downcase(value)

	# -------------------------------- UUID TYPE ----------------

	scalar :uuid, name: "UUID" do
		description("""
		The `UUID` scalar type represents UUID4 compliant string data, represented as UTF-8
		character sequences. The UUID4 type is most often used to represent unique
		human-readable ID strings.
		""")
		# Input format, json to elixir
		parse(&decode_uuid/1)
		# Output format, elixir to json
		serialize(&encode_uuid/1)
	end

	# Validate input with String type
	@spec decode_uuid(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
	# Validate input with Null type
	@spec decode_uuid(Absinthe.Blueprint.Input.Null.t()) :: :error

	# Function to parse a string data from elixir to json
	defp decode_uuid(%Absinthe.Blueprint.Input.String{value: value}) do
		Ecto.UUID.cast(value)
	end

	# Function to parse a null type
	defp decode_uuid(%Absinthe.Blueprint.Input.Null{}) do
		:error
	end

	# Function to parse data from elixir to json
	defp decode_uuid(_) do
		:error
	end

	# Function to serialize
	defp encode_uuid(value), do: value

	# -------------------------------- JSON/MAP TYPE ----------------

	scalar :map, name: "json_map" do
		description("""
		The `Map` scalar type represents arbitrary JSON string data, represented as UTF-8
		character sequences. The JSON type is most often used to represent a free-form
		human-readable JSON string.
		""")

		serialize(&encode_map/1)
		parse(&decode_map/1)
	end

	# Validate input with String type
	@spec decode_map(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
	# Validate input with Null type
	@spec decode_map(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}

	defp decode_map(%Absinthe.Blueprint.Input.String{value: value}) do
		if String.length(value) <= 10_000 do
			case Poison.decode(value) do
				{:ok, value} -> {:ok, value}
				_error -> :error
			end
		else
			:error
		end
	end

	defp decode_map(%Absinthe.Blueprint.Input.Null{}) do
		{:ok, nil}
	end

	defp decode_map(_) do
		:error
	end

	defp encode_map(value), do: value

	# -------------------------------- DATE TYPES ----------------

	scalar :datetime, name: "DateTime" do
		description("""
		The `DateTime` scalar type represents a date with time, the format is YYYY-MM-DD HH:mm:ssZ
		""")
		# Input format, json to elixir
		parse(&decode_datetime / 1)
		# Output format, elixir to json
		serialize(&encode_datetime / 1)
	end

	# Validate input with String type
	@spec decode_datetime(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
	# Validate input with Null type
	@spec decode_datetime(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}

	# Function to parse a string data from elixir to json
	defp decode_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
		case DateTime.from_iso8601(value) do
			{:ok, date, _offset} -> {:ok, date}
			{:error, _error} -> NaiveDateTime.from_iso8601(value)
		end
		|> case do
			{:ok, date} -> {:ok, date}
			{:error, _error} -> :error
		end
	end

	# Function to parse a null type
	defp decode_datetime(%Absinthe.Blueprint.Input.Null{}) do
		{:ok, nil}
	end

	# Function to parse data from elixir to json
	defp decode_datetime(_) do
		:error
	end

	# Function to serialize
	defp encode_datetime(value) do
		case DateTime.from_naive(value, "Etc/UTC") do
			{:ok, value} -> DateTime.to_iso8601(value)
			{:error, _} -> :error
		end
	end

	scalar :date, name: "Date" do
		description("""
		The `Date` scalar type represents a date, the format is YYYY-MM-DD
		""")
		# Input format, json to elixir
		parse(&decode_date / 1)
		# Output format, elixir to json
		serialize(&encode_date / 1)
	end

	# Validate input with String type
	@spec decode_date(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
	# Validate input with Null type
	@spec decode_date(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}

	# Function to parse a string data from elixir to json
	defp decode_date(%Absinthe.Blueprint.Input.String{value: value}) do
		if String.contains?(value, " ") do
			[a_date, _a_time] = String.split(value, " ")
			case Date.from_iso8601(a_date) do
				{:ok, date} -> {:ok, date}
				{:error, _error} -> :error
			end
		else
			case Date.from_iso8601(value) do
				{:ok, date} -> {:ok, date}
				{:error, _error} -> :error
			end
		end
	end

	# Function to parse a null type
	defp decode_date(%Absinthe.Blueprint.Input.Null{}) do
		{:ok, nil}
	end

	# Function to parse data from elixir to json
	defp decode_date(_) do
		:error
	end

	# Function to serialize
	defp encode_date(value) do
		value
	end

	scalar :time, name: "Time" do
		description("""
		The `Time` scalar type represents an hour, the format is HH:mm:ss
		""")
		# Input format, json to elixir
		parse(&decode_time/1)
		# Output format, elixir to json
		serialize(&encode_time/1)
	end

	# Validate input with String type
	@spec decode_time(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
	# Validate input with Null type
	@spec decode_time(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}

	# Function to parse a string data from elixir to json
	defp decode_time(%Absinthe.Blueprint.Input.String{value: value}) do
		case Time.from_iso8601(value) do
			{:ok, time} -> {:ok, time}
			{:error, _error} -> :error
		end
	end

	# Function to parse a null type
	defp decode_time(%Absinthe.Blueprint.Input.Null{}) do
		{:ok, nil}
	end

	# Function to parse data from elixir to json
	defp decode_time(_) do
		:error
	end

	# Function to serialize
	defp encode_time(value) do
		Time.to_iso8601(value)
	end

	# -------------------------------- b64_content TYPE ----------------

	scalar :b64_content, name: "b64_content" do
		description """
		The 'b64_content' scalar type represents an Base64 encoded dataset
		"""
		#Input Format
		parse(&decode_b64_content/1)
		#Output Format
		serialize(&encode_b64_content/1)
	end

	# Validate input with String type
	@spec decode_b64_content(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
	# Validate input with NULL type
	@spec decode_b64_content(Absinthe.Blueprint.Input.Null.t()) :: :error

	# Function to parse
	defp decode_b64_content(%Absinthe.Blueprint.Input.String{value: value}) do
		case Base.decode64(value) do
			{:ok, value} -> {:ok, value}
			_error	-> :error
		end
	end

	defp decode_b64_content(%Absinthe.Blueprint.Input.Null{}), do: :error

	defp decode_b64_content(_), do: :error

	defp encode_b64_content(value), do: {:ok, value}

		# -------------------------------- ANY TYPE ----------------

		# -------------------------------- URL TYPE ----------------

end
