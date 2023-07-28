defmodule TaxLotTest do
  use ExUnit.Case
  alias Decimal, as: D

  setup do
    {:ok, state: LotManager.new()}
  end

  describe "parse_line/1" do
    test "creates a TaxLot struct with id of nil" do
      lot = %TaxLot{
        id: nil,
        date: "2021-01-01",
        action: "buy",
        price: D.new("10000.00"),
        quantity: D.new("1.00000000")
      }

      parsed_value = TaxLot.parse_line("2021-01-01,buy,10000.00,1.00000000")
      assert lot == parsed_value
    end
  end

  describe "process_lot/2" do
    test "process_lot adds transaction when action is buy", %{state: state} do
      lot = %TaxLot{
        id: 1,
        date: "2021-10-05",
        action: "buy",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(state, {"fifo", lot})

      assert length(new_state.lots) == 1
      assert new_state.lots |> hd |> Map.get(:id) == lot.id
    end

    test "process_lot removes transaction when action is sell", %{state: state} do
      buy_lot = %TaxLot{
        id: 1,
        date: "2021-10-05",
        action: "buy",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(state, {"fifo", buy_lot})

      sell_lot = %TaxLot{
        id: 2,
        date: "2021-10-06",
        action: "sell",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(new_state, {"fifo", sell_lot})

      assert length(new_state.lots) == 0
    end

    test "process_lot combines first and second transactions when date is the same", %{
      state: state
    } do
      buy_lot = %TaxLot{
        id: 1,
        date: "2021-10-05",
        action: "buy",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(state, {"hifo", buy_lot})

      buy_lot2 = %TaxLot{
        id: 2,
        date: "2021-10-05",
        action: "buy",
        price: D.new("200.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(new_state, {"hifo", buy_lot2})

      assert length(new_state.lots) == 1
      assert new_state.lots |> hd |> Map.get(:id) == buy_lot.id
    end

    test "process_lot removes first transaction when action is sell", %{state: state} do
      buy_lot = %TaxLot{
        id: 1,
        date: "2021-10-05",
        action: "buy",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(state, {"fifo", buy_lot})

      buy_lot2 = %TaxLot{
        id: 2,
        date: "2021-10-06",
        action: "buy",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(new_state, {"fifo", buy_lot2})

      sell_lot = %TaxLot{
        id: 3,
        date: "2021-10-06",
        action: "sell",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(new_state, {"fifo", sell_lot})

      assert length(new_state.lots) == 1
      assert new_state.lots |> hd |> Map.get(:id) == buy_lot2.id
    end

    test "process_lot removes second transaction when action is sell", %{state: state} do
      buy_lot = %TaxLot{
        id: 1,
        date: "2021-10-05",
        action: "buy",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(state, {"hifo", buy_lot})

      buy_lot2 = %TaxLot{
        id: 2,
        date: "2021-10-06",
        action: "buy",
        price: D.new("200.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(new_state, {"hifo", buy_lot2})

      sell_lot = %TaxLot{
        id: 3,
        date: "2021-10-06",
        action: "sell",
        price: D.new("100.00"),
        quantity: D.new("1.00000000")
      }

      {:ok, new_state} = TaxLot.process_lot(new_state, {"hifo", sell_lot})

      assert length(new_state.lots) == 1
      assert new_state.lots |> hd |> Map.get(:id) == buy_lot.id
    end
  end
end
