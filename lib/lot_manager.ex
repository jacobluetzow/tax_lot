defmodule LotManager do
  alias Decimal, as: D

  defstruct lots: [], last_id: 0

  def new do
    %__MODULE__{}
  end

  def add_transaction(%{lots: lots} = state, lot) do
    case find_lot_by_key(lots, :date, lot.date) do
      nil ->
        new_lot = Map.put(lot, :id, state.last_id + 1)

        {:ok,
         %{
           state
           | lots: lots ++ [new_lot],
             last_id: new_lot.id
         }}

      %{price: old_price, quantity: old_quantity} = old_lot ->
        total_old_value = D.mult(old_price, old_quantity)
        total_new_value = D.mult(lot.price, lot.quantity)
        total_quantity = D.add(old_quantity, lot.quantity)

        weighted_avg_price = D.div(D.add(total_old_value, total_new_value), total_quantity)
        updated_lot = %{old_lot | price: weighted_avg_price, quantity: total_quantity}
        {:ok, %{state | lots: update_lot(lots, updated_lot), last_id: old_lot.id}}
    end
  end

  def remove_transaction(%{lots: lots} = state, {"fifo", sell}) do
    sorted_list = Enum.sort_by(lots, fn lot -> lot.id end)

    {:ok, %{state | lots: deduct_value_from_lots(sorted_list, sell.quantity)}}
  end

  def remove_transaction(%{lots: lots} = state, {"hifo", sell}) do
    sorted_list = Enum.sort_by(lots, fn lot -> lot.price end, &>=/2)

    {:ok, %{state | lots: deduct_value_from_lots(sorted_list, sell.quantity)}}
  end

  def remove_transaction(_state, _transaction) do
    IO.puts("Error: Unrecognized strategy type. Expected: fifo or hifo")
    System.halt(1)
  end

  defp deduct_value_from_lots([], _value_to_deduct), do: []

  defp deduct_value_from_lots([%{quantity: quantity} = lot | rest_lots], value_to_deduct) do
    remaining_quantity = D.sub(quantity, value_to_deduct)

    if D.gt?(remaining_quantity, 0) do
      [%{lot | quantity: remaining_quantity} | rest_lots]
    else
      deduct_value_from_lots(rest_lots, D.abs(remaining_quantity))
    end
  end

  defp find_lot_by_key(lots, key, value) do
    Enum.find(lots, fn lot ->
      Map.from_struct(lot)[key] == value
    end)
  end

  defp update_lot(lots, new_lot) do
    Enum.map(lots, fn lot ->
      if lot.id == new_lot.id do
        new_lot
      else
        lot
      end
    end)
  end
end
