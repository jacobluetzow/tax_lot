defmodule TaxLot do
  alias Decimal, as: D

  defstruct [:id, :date, :action, :price, :quantity]

  @moduledoc """
  synopsis:
    This script takes in one argument which is the tax lot selection algorithm:

    fifo - the first lots bought are the first lots sold
    hifo - the first lots sold are the lots with the highest price
    The script processes an ordered transaction log read from stdin in the format of date,buy/sell,price,quantity separated by line breaks.

    It then prints to stdout the remaining lots after the transaction log is processed in the format of id,date,price,quantity.

  usage:
    input = date,buy/sell,price,quantity
    algorithm = fifo or hifo
    remaining_lots = id,date,price,quantity
    $ echo -e 'input1\\ninput2\\n....' | ./tax_lot algorithm
    remaining_lots

  ## Examples
    $ echo -e '2021-01-01,buy,10000.00,1.00000000\\n2021-02-01,sell,20000.00,0.50000000' | ./tax_lot fifo
    1,2021-01-01,10000.00,0.50000000

    $ echo -e '2021-01-01,buy,10000.00,1.00000000\\n2021-01-02,buy,20000.00,1.00000000\\n2021-02-01,sell,20000.00,1.50000000' | ./tax_lot fifo
    2,2021-01-02,20000.00,0.50000000

    $ echo -e '2021-01-01,buy,10000.00,1.00000000\\n2021-01-02,buy,20000.00,1.00000000\\n2021-02-01,sell,20000.00,1.50000000' | ./tax_lot hifo
    1,2021-01-01,10000.00,0.50000000
  """

  def main([help_opt]) when help_opt == "-h" or help_opt == "--help" do
    IO.puts(@moduledoc)
  end

  def main(args) do
    case args do
      [strategy] ->
        IO.stream(:stdio, :line)
        |> Enum.reduce(LotManager.new(), fn lot, state ->
          parsed_lot =
            lot
            |> String.trim()
            |> parse_line

          {:ok, state} = process_lot(state, {strategy, parsed_lot})
          state
        end)
        |> output_remaining

      _ ->
        IO.puts("Error: Strategy Required. See help with -h or --help")
        System.halt(1)
    end
  end

  def parse_line(line) do
    [date, action, price, quantity] = String.split(line, ",")
    %TaxLot{date: date, action: action, price: D.new(price), quantity: D.new(quantity)}
  end

  def process_lot(state, {_strategy, %TaxLot{action: "buy"} = lot}) do
    LotManager.add_transaction(state, lot)
  end

  def process_lot(state, {strategy, %TaxLot{action: "sell"} = lot}) do
    LotManager.remove_transaction(state, {strategy, lot})
  end

  def process_lot(_state, _transaction) do
    IO.puts("Error: Unrecognized transaction type. Expected: buy or sell")
    System.halt(1)
  end

  defp output_remaining(state) do
    Enum.each(state.lots, fn lot ->
      IO.puts("#{lot.id},#{lot.date},#{D.round(lot.price, 2)},#{D.round(lot.quantity, 8)}")
    end)
  end
end
