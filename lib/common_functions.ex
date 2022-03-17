defmodule SalsaCrm.CommonFunctions do
    @moduledoc """
    This module defines general purpose functions used through all the application.
    """
    alias SalsaCrm.CommonFunctions
  
    @aad "AES256GCM"
    # Functions
  
    @doc """
    Splits the duplicated elements and the unique elements
    The function adds the first ocurrence of the element
  
    Taken from https://elixirforum.com/t/getting-duplicates-instead-of-unique-values/15713/5
    """
    def split_uniq(enumerable) do
      split_uniq_by(enumerable, fn x -> x end)
    end
  
    @doc """
    Splits the duplicated elements and the unique elements using the declared function
    The function adds the first ocurrence of the element
  
    Taken from https://elixirforum.com/t/getting-duplicates-instead-of-unique-values/15713/5
    """
    def split_uniq_by(enumerable, fun) when is_list(enumerable) do
      split_uniq_list(enumerable, %{}, fun)
    end
  
    # Function eavluate every value and use recursion
    defp split_uniq_list([head | tail], set, fun) do
      # Apply the function to the head entry element
      value = fun.(head)
      # Evaluate if the value exist in the result set
      case set do
        %{^value => true} ->
          {uniq, dupl} = split_uniq_list(tail, set, fun)
          {uniq, [head | dupl]}
        %{} ->
          {uniq, dupl} = split_uniq_list(tail, Map.put(set, value, true), fun)
          {[head | uniq], dupl}
      end
    end
  
    # Function split_uniq_list default case
    defp split_uniq_list([], _set, _fun), do: {[], []}
  
    @doc """
    Validates thestrucutre of the accounting party for each case
    """
    def validate_additional_account_id(party_map) do
      %{
        additional_account_id: additional_account_id
      } = CommonFunctions.map_keys_as_atoms(party_map)
  
      if Enum.member?([1, 2], additional_account_id) do
        true
      else
        false
      end
    end
  
    @regex ~r/(?<sign>-?)(?<int>\d+)(\.(?<frac>\d+))?/
  
    def format_number(number, options \\ []) do
      number = Decimal.round(number, 2)
      thousands_separator = Keyword.get(options, :thousands_separator, ".")
      parts = Regex.named_captures(@regex, to_string(number))
  
      formatted_int =
        parts["int"]
        |> String.graphemes
        |> Enum.reverse
        |> Enum.chunk_every(3)
        |> Enum.join(thousands_separator)
        |> String.reverse
  
      decimal_separator =
        if parts["frac"] == "" do
          ""
        else
          Keyword.get(options, :decimal_separator, ",")
        end
  
      to_string [parts["sign"], formatted_int, decimal_separator, parts["frac"]]
    end
  
    @doc """
    Transforms the keys of a map to atoms safely when possible (It only creates an atom when it does not exist).
    """
    def map_keys_as_atoms(map?) when map? |> is_map() do
      if map? |> Map.has_key?(:__struct__) do
        map?
        |> Map.delete(:__struct__)
        |> Map.delete(:__meta__)
      else
        map?
      end
      |> Enum.map(fn x -> x end)
      |> Enum.map(fn {k, v} ->
        {to_atom_safely(k), if String.downcase(to_string(k)) |> String.contains?("date") do
          v
        else
          map_keys_as_atoms(v)
        end}
      end)
      |> Enum.into(%{})
    end
  
    @doc """
    Transforms the keys of a map list to atoms safely when possible (It only creates an atom when it does not exist).
    """
    def map_keys_as_atoms([_head | _tail] = map_list) do
      Enum.map(map_list, fn map? ->
        map_keys_as_atoms(map?)
      end)
    end
  
    @doc """
    Default case for non map values. It returns the argument `map?`.
    """
    def map_keys_as_atoms(map?), do: map?
  
    @doc """
    Split a datetime and returns it as a list
    """
  
    @months %{1 => "enero", 2 => "febrero", 3 => "marzo", 4 => "abril", 5 => "mayo", 6 => "junio", 7 => "julio", 8 => "agosto", 9 => "septiembre", 10 => "octubre", 11 => "noviembre", 12 => "diciembre"}
  
    # SalsaCrm.CommonFunctions.get_month(3)
    def get_month(month_number) do
      Map.get(@months, month_number)
    end
  
    # SalsaCrm.CommonFunctions.add_month(Date.new(2022, 1, 13))
    def add_month(date) do
      days = Date.days_in_month(date)
      Date.add(date, days)
    end
  
    # SalsaCrm.CommonFunctions.sub_month(Date.new(2022, 1, 13))
    def sub_month(%Date{day: day} = date) do
      days = max(day, (Date.add(date, -day)).day)
      Date.add(date, -days)
    end
  
    @charge_day %{1 => 13, 5 => 17, 10 => 22, 15 => 27, 20 => 1}
  
    # SalsaCrm.CommonFunctions.get_charge(1)
    def get_charge(payment_day) do
      Map.get(@charge_day, payment_day)
    end

    # @charge_day %{1 => 13, 5 => 17, 10 => 22, 15 => 27, 20 => 1}
  
    # # SalsaCrm.CommonFunctions.get_charge(1)
    # def get_apy(payment_day) do
    #   Map.get(@charge_day, payment_day)
    # end
  
    @doc """
    Returns the parameters map for a specific key from a map
    with multiple keys and their parameters
  
    ## Example input
  
        %{filter: %{organization_uuid: "...", ...}, page_size: n, ...}
  
    ## Example output
  
        get_parameters_for_query(%{...}, :filter)
        %{filter: %{organization_uuid: "...", ...}}
  
    """
    def get_parameters_for_query(params, key) do
      if Map.has_key?(params, key) do
        Map.fetch!(params, key) 
      else
        %{}
      end
    end
  
    @doc """
    Converts an `String` list to an `atom` list
    """
    def string_list_to_atom_list(string_list) do
      try do
        Enum.map(string_list,
          fn s ->
            String.to_existing_atom(s)
          end)
      rescue
        ArgumentError -> nil
      end
    end
  
    # Error handler functions
  
    @doc """
    Formats an error related to an specific key
    """
    def cast_to_error(key, message) do
      {:error, %{key: key, message: message}}
    end
  
    @doc """
    Extracts errors from a changeset
    """
    def transform_errors(changeset) do
      changeset
      |> Ecto.Changeset.traverse_errors(&format_error/1)
      |> Enum.map(fn {key, value} -> %{key: key, message: value} end)
    end
  
    @doc """
    Extracts errors from an authapi response
    """
    def transform_errors_authapi(errors) do
      Enum.map(errors, fn {error, value} ->
        if is_map(value) do
          %{key: error, message: transform_errors_authapi(value)}
        else
          %{key: error, message: value}
        end
      end)
    end
  
    @doc """
    Casts and rebuilds the messages and keys from a changeset
    """
    @spec format_error(Ecto.Changeset.error) :: String.t
    def format_error({msg, opts}) do
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end
  
    @doc """
    Evaluates the type of a incoming value, passing the type and the value to evaluate. Returns a boolean
  
    * Accepted Types:
      * Boolean
      * Float
      * Integer
      * List
      * Number (Integer or Float)
      * String (BitString)
      * Map (JSON)
    """
    def validate_type?(item, value) do
      cond do
        :boolean == item[:type] ->
          # IO.puts "It's a boolean"
          is_boolean(value)
        :float == item[:type] ->
          # IO.puts "It's a float"
          is_float(value)
        :integer == item[:type] ->
          # IO.puts "It's an integer"
          is_integer(value)
        :list == item[:type] ->
          # IO.puts "It's a list"
          is_list(value)
        :number == item[:type] ->
          # IO.puts "It's a number"
          is_number(value)
        :string == item[:type] ->
          # IO.puts "It's a string"
          is_bitstring(value)
        :map == item[:type] ->
          is_map(value)
        # Default case
        true ->
          false
      end
    end
  
    @doc """
    Evaluates if the incoming JSON has all the keys in @map_require. Returns an array
    """
    def validate_map_struct(struct, map) do
      Enum.reduce_while(struct, [] , fn item, acc ->
        if Map.has_key?(map, item[:key]) do
          case :map == item[:type] do
            true ->
              case validate_map_struct(item[:data], map[item[:key]]) do
                [] -> {:cont, acc}
                [error] ->
                  {:halt, ["#{item[:key]} [#{error}]"] }
              end
            false -> {:cont, acc}
          end
        else
          {:halt, [item[:key]] }
        end
      end)
    end
  
    @doc """
    Evaluates if the JSON struct has the right types. Returns an array
    """
    def validate_map_types(struct, map) do
      Enum.reduce_while(struct, [] , fn item, acc ->
        if validate_type?(item, map[item[:key]]) do
          case :map == item[:type] do
            true ->
              case validate_map_types(item[:data], map[item[:key]]) do
                [] -> {:cont, acc}
                [error] ->
                  {:halt, ["#{item[:key]} [#{error}]"] }
              end
            false -> {:cont, acc}
          end
        else
          {:halt, [item[:key]] }
        end
      end)
    end
  
    @doc """
    Returns the additional account id
    """
    def get_additional_account_id(id_type) do
      case id_type do
        "31" -> 1
        _other_type -> 2
      end
    end
  
    @doc """
    Returns a random nonce
    """
    def get_nonce() do
      :rand.uniform()
      |> to_string()
      |> Base.encode64
    end
  
    @doc """
    Return a random nonce from a seed
    """
    def get_nonce(seed) do
      seed
      |> to_string()
      |> Base.encode64
    end
  
    @doc """
    Transforms an struct into a map recursively
    """
    def map_from_struct(struct) do
      map_as_list =
        Map.from_struct(struct)
        |> Enum.map(fn x -> x end)
  
        Enum.into(map_from_keyword_list(map_as_list), %{})
    end
  
    defp map_from_keyword_list([head | tail]) do
      if head |> elem(1) |> is_map() do
        if Map.has_key?(elem(head, 1), :__struct__) do
          [{elem(head, 0), Enum.into(map_from_struct(elem(head, 1)), %{})} | map_from_keyword_list(tail)]
        else
          [{elem(head, 0), Enum.into(map_from_keyword_list(Enum.map(elem(head, 1), fn x -> x end)), %{})} | map_from_keyword_list(tail)]
        end
      else
        [head | map_from_keyword_list(tail)]
      end
    end
  
    defp map_from_keyword_list([]) do
      []
    end
  
    @doc """
    Tries to make a conversion to an atom type safely. If `value` is not a string `value` is returned.
    """
    def to_atom_safely(value) do
      case to_atom_safely!(value) do
        {:error, _error} -> value
        result -> result
      end
    end
  
    @doc """
    Tries to make a conversion to an atom type safely. If `value` is not a string an error is returned.
    """
    def to_atom_safely!(value) do
      if is_bitstring(value) do
        try do
          String.to_existing_atom(value)
        rescue
          ArgumentError -> String.to_atom(value)
        end
      else
        {:error, "That's not a string!! ¬_¬"}
      end
    end
  
    def string_to_map(text) when is_bitstring(text) do
      text
      |> String.split(";")
      |> case do
        [""] -> []
        string_list ->
          Enum.map(string_list, fn string ->
            [key, value] = String.split(string, ":")
            {
              String.replace_leading(key, " ", "")
              |> String.replace_trailing(" ", ""),
              String.replace_leading(value, " ", "")
              |> String.replace_trailing(" ", "")
            }
          end)
      end
      |> Enum.into(%{})
    end
  
    def string_to_map(_text) do
      %{}
    end
  
    def list_to_map(list) do
      list
      |> Enum.map(fn %{
        "name" => name,
        "value" => value
      } ->
        {name, value}
      end)
      |> Enum.into(%{})
    end
  
    def string_to_number(number) do
      string_to_number(number, [])
    end
  
    def string_to_number(number, _options) do
      if is_bitstring(number) do
        try do
          String.to_float(number)
        rescue
          ArgumentError -> try do
            String.to_integer(number)
          rescue
            ArgumentError -> {:error, "That's not a number!! ¬_¬"}
          end
        end
      else
        {:error, "That's not a number!! ¬_¬"}
      end
    end
  
    def standardize_date_time(date_time, options \\ []) when is_map(date_time) do
      {
        Keyword.get(options, :words?, false),
        Map.merge(%{
          std_offset: 0,
          time_zone: "Etc/UTC",
          utc_offset: 0,
          zone_abbr: "UTC"
        }, date_time)
        |> DateTime.truncate(:second)
      }
      |> case do
        {true, datetime} -> DateTime.to_iso8601(datetime)
        {false, datetime} -> datetime
        _error -> :error
      end
    end
  
    def url?(url) when is_bitstring(url) do
      exp = ~r/((http(s)?(\:\/\/))+(www\.)?([\w\-\.\/])*(\.[a-zA-Z]{2,3}\/?))[^\s\b\n|]*[^.,;:\?\!\@\^\$ -]/
      case Regex.run(exp, url) do
        nil -> :nope
        _else -> url
      end
    end
  
    def xml_to_map(xml) do
      XmlToMap.naive_map(xml)
      |> Enum.map(fn {k, v} ->
        {format_key(k), format_keys(v)}
      end)
      |> Enum.into(%{})
    end
  
    defp format_key(key) when is_bitstring(key) do
      String.contains?(key, "}")
      |> if do
        String.split(key, "}")
        |> Enum.at(1)
      else
        key
      end
    end
  
    defp format_keys(map) when is_map(map) do
      map
      |> Enum.map(fn {k, v} ->
        {format_key(k), format_keys(v)}
      end)
      |> Enum.into(%{})
    end
  
    defp format_keys(map) when is_list(map) do
      map
      |> Enum.map(fn e ->
        format_keys(e)
      end)
    end
  
    defp format_keys(not_a_map) do
      not_a_map
    end
  
    @doc """
    Validates an id string based on it's type.
    """
    def validate_id(id?, type) when is_bitstring(id?) do
      case type do
        # Registro civil
        "11" ->
          Regex.run(~r/^[0-9]+$/, id?) != nil
        # Tarjeta de identidad
        "12" ->
          Regex.run(~r/^[0-9]+$/, id?) != nil
        # Cédula de ciudadanía
        "13" ->
          Regex.run(~r/^[0-9]+$/, id?) != nil
        # Tarjeta de extranjería
        "21" ->
          true
          # Regex.run(, id?) |> is_nil()
        # Cédula de extranjería
        "22" ->
          # Regex.run(, id?) |> is_nil()
          true
        # NIT
        "31" ->
          Regex.run(~r/^[0-9]{7,}-[0-9]$/, id?) != nil
        # Pasaporte
        "41" ->
          # Regex.run(, id?) |> is_nil()
          true
        # Documento de identificación extranjero
        "42" ->
          # Regex.run(, id?) |> is_nil()
          true
        # NIT de otro país
        "50" ->
          # Regex.run(, id?) |> is_nil()
          true
        # NUIP *
        "91" ->
          Regex.run(~r/^[0-9]+$/, id?) |> is_nil()
        _else -> false
      end
    end

    
    # This functions returns the different date formats required to create a partition table
  
    # Examples
    # iex> get_data_to_partition_tables(
    # {"2020", "01", %Date{}, 31}
    # )
    defp get_data_to_partition_tables() do
      date  = :calendar.local_time() |> elem(0)
      year  = date |> elem(0)
      month = date |> elem(1)
      {:ok, s_date} = Date.new(year, month, 1)
      e_date = s_date |> Date.add(Date.days_in_month(s_date))
      name = "#{year}_#{month}"
      {name, s_date |> Date.to_iso8601(), e_date |> Date.to_iso8601()}
    end
  
    # Create the partition of a table with the given information.
    defp create_partition(schema, table, partition_by, name, start_date, end_date) do
      Ecto.Adapters.SQL.query!(SalsaCrm.Repo, """
      CREATE TABLE IF NOT EXISTS #{schema}.#{table}_#{String.replace(partition_by, "-", "_")}
      PARTITION OF #{schema}.#{table}
      FOR VALUES IN ('#{partition_by}')
      PARTITION BY RANGE (inserted_at);
      """, [])
      Ecto.Adapters.SQL.query!(SalsaCrm.Repo, """
      CREATE TABLE IF NOT EXISTS #{schema}.#{table}_#{String.replace(partition_by, "-", "_")}_#{name}
      PARTITION OF #{schema}.#{table}_#{String.replace(partition_by, "-", "_")}
      FOR VALUES FROM ('#{start_date}') TO ('#{end_date}');
      """, [])
    end
  
    # Check the existence of a partition table, if the table does not exists is created, otherwise is not.
    def check_partition(schema, table, partition_by) do
      {name, start_date, end_date} = get_data_to_partition_tables()
      Ecto.Adapters.SQL.query(SalsaCrm.Repo, """
      select schemaname, relname
      from pg_stat_user_tables
      where schemaname ilike '#{table}' and relname ilike '#{table}_#{String.replace(partition_by, "-", "_")}_#{name}'
      """)
      |> case do
        {:ok, %Postgrex.Result{num_rows: 0, rows: []}} ->
          create_partition(schema, table, partition_by, name, start_date, end_date)
        _else -> IO.puts "#{table}_#{partition_by}_#{name} Exists."
      end
    end
  
    def create_route(beneficiary_uuid, process_uuid) do
      if File.exists?(File.cwd! <> "/priv/static/documents/" <> beneficiary_uuid <> "/" <> process_uuid) == false do
        File.mkdir_p(File.cwd! <> "/priv/static/documents/" <> beneficiary_uuid <> "/" <> process_uuid)
      end
    end
  
    def save_file(doc, doc_name, ext, beneficiary_uuid, process_uuid) do
      doc
      |> Base.decode64()
      |> case do
        {:ok, doc} ->
          timestamp = DateTime.utc_now
          |> DateTime.to_string()
          |> String.replace(["-", " ", ":", "."], "")
  
          name = doc_name <> timestamp <> ext
          route = File.cwd! <> "/priv/static/documents/" <> beneficiary_uuid <> "/" <> process_uuid <> "/" <> name
          File.write!(route, doc)
          name
        _error ->
          IO.puts("Se produjo un error al guardar el archivo " <> doc_name)
      end
    end
  
    def save_file(doc, doc_name, ext, beneficiary_uuid) do
      doc
      |> Base.decode64()
      |> case do
        {:ok, doc} ->
          timestamp = DateTime.utc_now
          |> DateTime.to_string()
          |> String.replace(["-", " ", ":", "."], "")
  
          name = doc_name <> timestamp <> ext
          route = File.cwd! <> "/priv/static/documents/" <> beneficiary_uuid <> "/" <> name
          File.write!(route, doc)
          name
        _error ->
          IO.puts("Se produjo un error al guardar el archivo " <> doc_name)
      end
    end
  
    def save_pdf(doc, doc_name, beneficiary_uuid, process_uuid) do
      timestamp = DateTime.utc_now
      |> DateTime.to_string()
      |> String.replace(["-", " ", ":", "."], "")
  
      name = doc_name <> timestamp <> ".pdf"
      create_route(beneficiary_uuid, process_uuid)
      route = File.cwd! <> "/priv/static/documents/" <> beneficiary_uuid <> "/" <> process_uuid <> "/" <> name
  
      File.write!(route, doc)
      name
    end
  
    def get_file(doc_name, beneficiary_uuid, process_uuid) do
      # route = File.cwd! <> "/priv/static/images/1.jpg"
      route = File.cwd! <> "/priv/static/documents/" <> beneficiary_uuid <> "/" <> process_uuid <> "/" <> doc_name
      File.read(route)
      |> case do
        {:ok, doc} ->
          doc_file = Base.encode64(doc)
          {:ok, doc_file}
        error ->
          error
      end
    end
  
    def get_file_ep(doc_name, beneficiary_uuid) do
      route = File.cwd! <> "/priv/static/documents/" <> beneficiary_uuid <> "/" <> doc_name
      File.read(route)
      |> case do
        {:ok, doc} ->
          doc_file = Base.encode64(doc)
          {:ok, doc_file}
        error ->
          error
      end
    end
  
    def shrink_file(route) do
      System.cmd "shrinkpdf", [
        "#{route}",
        "#{route}_temp.pdf"
      ]
  
      System.cmd "mv", [
        "#{route}_temp.pdf",
        "#{route}"
      ]
    end
  
    def shrink_file_prod(route) do
      Task.start_link(__MODULE__, :shrink_file, [route])
      IO.puts("En proceso")
    end
  
    @doc """
      Generate a 16-digit random number using the luhn algorithm.
    """
    def generate_number do
        number = Enum.random(1_000_000_000_000_000..9_999_999_999_999_999)
        split_digits(number)
    end
  
    @doc """
      Generate a 6-digit random number using the luhn algorithm.
    """
    def generate_ttl do
        number = Enum.random(100_000..999_999)
        split_digits(number)
    end
  
    @doc """
      Generate a 4-digit random number using the luhn algorithm.
    """
    def generate_four_digit do
      number = Enum.random(1_000..9_999)
      split_digits(number)
    end
  
    def split_digits(number) do
        digits = Integer.digits(number)
        update_list(digits, digits, 0)
    end
  
    def update_list(oroginal_list, digits_list, index) do
        if index < Enum.count(digits_list) - 1 do
            new = Enum.fetch!(digits_list, index) * 2
            if new > 9 do
                new = new - 9
                digits_list = List.replace_at(digits_list, index, new)
                update_list(oroginal_list, digits_list, index + 2)
            else
                digits_list = List.replace_at(digits_list, index, new)
                update_list(oroginal_list, digits_list, index + 2)
            end
        else
            luhn_conversion(oroginal_list, digits_list)
        end
    end
  
    def luhn_conversion(original_list, updated_list) do
        size = Enum.count(original_list) - 1
        updated_list = List.replace_at(updated_list, size, 0)
        digits_sum = Enum.sum(updated_list) * 9
        validate_number = Integer.mod(digits_sum, 10)
        original_list = List.replace_at(original_list, size, validate_number)
        Integer.undigits(original_list)
    end
  
    def read_csv do
      t = File.stream!("./file.csv")
      |> Stream.map(&String.trim(&1))
      |> Stream.map(&String.split(&1, ";"))
      |> Stream.filter(fn
        [_, _, "cutoff_date" | _] -> false
        [_, "NaN" | _] -> false
        _ -> true
      end) 
      Enum.map(t, fn x -> x end)
    end
  
    def get_file_web do
      %HTTPoison.Response{body: body} = HTTPoison.get!("https://www.treasury.gov/ofac/downloads/sdn.xml")
      File.write!("./test_xml.xml", body)
    end
  
    def encrypt(plaintext) do
      iv = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
      key = get_key()    # get the *latest* key in the list of encryption keys
      {ciphertext, tag} =
        :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
      iv <> tag <> ciphertext # "return" iv with the cipher tag & ciphertext
    end
  
    defp get_key do # this is a "dummy function" we will update it in step 3.3
      <<109, 182, 30, 109, 203, 207, 35, 144, 228, 164, 106, 244, 38, 242,
      106, 19, 58, 59, 238, 69, 2, 20, 34, 252, 122, 232, 110, 145, 54,
      241, 65, 16>> # return a random 32 Byte / 128 bit binary to use as key.
    end
  
    def decrypt(ciphertext) do
      <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
      :crypto.block_decrypt(:aes_gcm, get_key(), iv, {@aad, ciphertext, tag})
    end
  
    def error_struct(error) do
      %{
        id: "001",
        message: error,
        language: "en-US"
      }
    end
  
    def autentication_token(token) do
      request_url = System.get_env("IDM_URL")
      {:ok, response} = HTTPoison.get(request_url, [{"Authorization", "bearer #{token}"}], [])
      authorized = response.body
  
      if authorized == "Unauthorized" do 
        false 
      else
        id = authorized
        |> Poison.decode!
  
        id["sub"]
      end
    end
  
    def round_to_fifty(decimal) do
      decimal = decimal |> Decimal.round() 
      rem = decimal |> Decimal.rem(50)
      if Decimal.to_integer(Decimal.compare(rem, 25)) == -1, do: Decimal.sub(decimal, rem), else: Decimal.add(decimal, (Decimal.sub(50, rem)))
    end
  
    # SalsaCrm.CommonFunctions.round_to_fifty_floor("3742.58")
    def round_to_fifty_floor(decimal) do
      decimal = decimal |> Decimal.round(0, :floor)
      rem = decimal |> Decimal.rem(50)
      Decimal.sub(decimal, rem)
    end
  end
  