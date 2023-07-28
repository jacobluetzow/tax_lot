# Tax Lot Script

This script processes an ordered transaction log and outputs the remaining tax lots based on a selected algorithm.

## Building the Script

To build the executable script, follow these steps:

1. Ensure you have Elixir installed on your system. You can download Elixir [here](https://elixir-lang.org/install.html).
2. Clone this repository: `git clone git@github.com:jacobluetzow/tax_lot.git`
3. Navigate to the project directory: `cd <project_directory>`
4. Fetch the project dependencies: `mix deps.get`
5. Compile the project: `mix compile`
6. Build the executable script: `mix escript.build`

The executable script `tax_lot` will be generated in the project directory.

## Running the Script

The script reads from `stdin` and takes one argument, the tax lot selection algorithm (`fifo` or `hifo`).

Example:

```bash
echo -e '2021-01-01,buy,10000.00,1.00000000\n2021-02-01,sell,20000.00,0.50000000' | ./tax_lot fifo
```

## Script Help

```bash
./tax_lot -h
```
or
```bash
./tax_lot --help
```

## Running Tests

To run the automated tests for this project, use the command: 

`mix test`

## License

This project is licensed under the terms of the Apache License 2.0 license. See the [LICENSE](LICENSE) file.

