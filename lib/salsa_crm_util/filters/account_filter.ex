defmodule SalsaCrm.Filters.Salsa.Account do
	@moduledoc false
	import Ecto.Query, warn: false

	# Event handler fon instances
	def manage_event(event, order) do
		if event.model == SalsaCrm.Salsa.Account do
			case event.list? do
				true ->
					field = String.to_atom(order.field)
					result = search_list_by(event.filter, event.model)
					if order.list_order == "asc" do
						cond do
							order.field == "payments_made" ->
								order_by(result, asc: fragment("dashboard_data -> 'payments_made'"))
							order.field == "incomes" ->
								order_by(result, asc: fragment("dashboard_data -> 'incomes'"))
							true ->
								order_by(result, asc: ^field)
						end
					else
						cond do
							order.field == "payments_made" ->
								order_by(result, desc: fragment("dashboard_data -> 'payments_made'"))
							order.field == "incomes" ->
								order_by(result, desc: fragment("dashboard_data -> 'incomes'"))
							true ->
								order_by(result, desc: ^field)
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
			{:status, status}, query ->
				from q in query, where: ilike(fragment("?::text", q.status), ^"#{status}")
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
			{:account_id, account_id}, query ->
				from q in query, where: ilike(fragment("?::text", q.account_id), ^"#{account_id}")
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
  