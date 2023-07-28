# tax_lot/mix.exs

defmodule TaxLot.MixProject do
  use Mix.Project

  def project do
    [
      app: :tax_lot,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:decimal, "~> 2.0"}]
  end

  def escript do
    [main_module: TaxLot]
  end
end
