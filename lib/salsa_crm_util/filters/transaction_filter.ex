defmodule SalsaCrm.Filters.Salsa.Transaction do
	@moduledoc false
	import Ecto.Query, warn: false

	# Event handler fon instances
	def manage_event(event, order) do
		if event.model == SalsaCrm.Salsa.Transaction do
			case event.list? do
				true ->
					field = String.to_atom(order.field)
					result = search_list_by(event.filter, event.model)
					if order.list_order == "asc" do
						cond do
							true ->
								order_by(result, asc: ^field, asc: :id)
						end
					else
						cond do
							true ->
								order_by(result, desc: ^field, desc: :id)
						end
					end
				false ->
					search_by(event.filter, event.model)
			end
		end
	end

	defp query_for_list(query, filter) do
		Enum.reduce(filter, query, fn
			{:account_id, account_id}, query ->
				from q in query, where: ilike(fragment("?::text", q.account_id), ^"#{account_id}")
			{:source_id, source_id}, query ->
				from q in query, where: ilike(fragment("?::text", q.source_id), ^"#{source_id}")
			{:recipient_id, recipient_id}, query ->
				from q in query, where: ilike(fragment("?::text", q.recipient_id), ^"#{recipient_id}")
			{:status, status}, query ->
				from q in query, where: ilike(fragment("?::text", q.status), ^"#{status}")
			{:type, type}, query ->
				from q in query, where: ilike(fragment("?::text", q.type), ^"#{type}")
			{:value_type, value_type}, query ->
				from q in query, where: ilike(fragment("?::text", q.value_type), ^"#{value_type}")
			{:date_start, date_start}, query ->
				from q in query, where: fragment("?::text", q.date) >= ^"#{date_start}"
			{:date_end, date_end}, query ->
				from q in query, where: fragment("?::text", q.date) <= ^"#{Date.add(date_end, 1)}"
		end)
	end

	# Search function using a list
	defp search_list_by(filters, model) do
		Enum.reduce(filters, model, fn
			{:filter, filter}, query ->
				query
				|> query_for_list(filter)
		end)
	end

	# Singleton definition
	defp query_for_singleton(query, filter) do
		# Evaluate for every filter
		Enum.reduce(filter, query, fn
			{:id, uuid}, query ->
				from q in query, where: ilike(fragment("?::text", q.uuid), ^"#{uuid}")
			{:code, code}, query ->
				from q in query, where: ilike(fragment("?::text", q.code), ^"#{code}")
		end)
	end

	# Search function using in unique query
	defp search_by(filters, model) do
		Enum.reduce(filters, model, fn
			{:filter, filter},
				query -> query |> query_for_singleton(filter)
		end)
	end
end
  