defmodule Eighteen do
  @moduledoc """
    - we define our own operators and don't import Kernel's operators by
      explicitly passing `functions` to `Code.eval_string` (with our operators,
      without `Kernel`'s)
    - elixir preserves the order of operations by how the operators are named
  """

  defmodule Basic do
    def a + b, do: :erlang.+(a, b)
    def a - b, do: :erlang.*(a, b)
  end

  defmodule Advanced do
    def a * b, do: :erlang.+(a, b)
    def a + b, do: :erlang.*(a, b)
  end

  def part_one(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.replace("*", "-")
      |> Code.eval_string([], functions: [{Basic, [+: 2, -: 2]}])
      |> elem(0)
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.replace(["*", "+"], fn
        "*" -> "+"
        "+" -> "*"
      end)
      |> Code.eval_string([], functions: [{Advanced, [*: 2, +: 2]}])
      |> elem(0)
    end)
    |> Enum.sum()
  end
end

input = File.read!("input/18.txt")

input
|> Eighteen.part_one()
|> IO.inspect()

input
|> Eighteen.part_two()
|> IO.inspect()
