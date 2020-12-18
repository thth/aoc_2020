defmodule Eighteen do
  defmodule Basic do
    defstruct operator: [nil], total: [nil]

    def evaluate(expression), do: evaluate(expression, %Basic{})
    defp evaluate([], %Basic{total: [n]}), do: n
    ## integers
    defp evaluate([exp_h | exp_t],
      %Basic{total: [nil | total_t], operator: [nil | _]} = state)
      when is_integer(exp_h) do
      evaluate(exp_t, %Basic{state | total: [exp_h | total_t]})
    end
    defp evaluate([exp_h | exp_t],
      %Basic{total: [total_h | total_t], operator: ["+" | op_t]} = state)
      when is_integer(exp_h) do
      evaluate(exp_t, %Basic{state | total: [total_h + exp_h | total_t], operator: [nil | op_t]})
    end
    defp evaluate([exp_h | exp_t],
      %Basic{total: [total_h | total_t], operator: ["*" | op_t]} = state)
      when is_integer(exp_h) do
      evaluate(exp_t, %Basic{state | total: [total_h * exp_h | total_t], operator: [nil | op_t]})
    end

    ## operators
    defp evaluate([exp_h | exp_t],
      %Basic{operator: [nil | op_t]} = state) when exp_h in ["+", "*"] do
      evaluate(exp_t, %Basic{state | operator: [exp_h | op_t]})
    end

    ## parens
    defp evaluate(["(" | exp_t],
      %Basic{total: totals, operator: operators} = state) do
      evaluate(exp_t, %Basic{state | total: [nil | totals], operator: [nil | operators]})
    end
    defp evaluate([")" | exp_t],
      %Basic{total: [total_h, nil | total_t], operator: [nil, nil | op_t]} = state) do
      evaluate(exp_t, %Basic{state | total: [total_h | total_t], operator: [nil | op_t]})
    end
    defp evaluate([")" | exp_t],
      %Basic{total: [total_h, total_l | total_t], operator: [nil, "*" | op_t]} = state) do
      evaluate(exp_t, %Basic{state | total: [total_h * total_l | total_t], operator: [nil | op_t]})
    end
    defp evaluate([")" | exp_t],
      %Basic{total: [total_h, total_l | total_t], operator: [nil, "+" | op_t]} = state) do
      evaluate(exp_t, %Basic{state | total: [total_h + total_l | total_t], operator: [nil | op_t]})
    end
  end

  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&Basic.evaluate/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&advanced/1)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.filter(&(&1 != " "))
      |> Enum.map(fn char ->
        case Integer.parse(char) do
          :error -> char
          {n, ""} -> n
        end
      end)
    end)
  end

  defp advanced(expression) do
    if  "(" in expression do
      expression
      |> resolve_parens()
      |> advanced()
    else
      resolve_ops(expression)
    end
  end

  defp resolve_parens(expression), do: resolve_parens([], expression)
  defp resolve_parens(past, ["(" | rest]) do
    first_open = Enum.find_index(rest, &(&1 == "("))
    first_close = Enum.find_index(rest, &(&1 == ")"))
    if is_nil(first_open) or first_close < first_open do
      in_parens = Enum.slice(rest, 0, first_close)
      past ++ [resolve_ops(in_parens) | Enum.slice(rest, (first_close + 1)..-1)]
    else
      resolve_parens(past ++ ["("], rest)
    end
  end
  defp resolve_parens(past, [head | rest]), do: resolve_parens(past ++ [head], rest)

  defp resolve_ops(expression), do: resolve_ops(:+, [], expression)
  defp resolve_ops(_, [], [n]), do: n
  defp resolve_ops(:+, past, [n, "+", m | rest]) when is_integer(n) and is_integer(m) do
    resolve_ops(:+, [], past ++ [n + m | rest])
  end
  defp resolve_ops(:+, past, [a, b, c | rest]), do: resolve_ops(:+, past ++ [a], [b, c | rest])
  defp resolve_ops(:+, past, [_, _] = rest), do: resolve_ops(:*, [], past ++ rest)
  defp resolve_ops(:*, past, [n, "*", m | rest]) when is_integer(n) and is_integer(m) do
    resolve_ops(:+, [], past ++ [n * m | rest])
  end
  defp resolve_ops(:*, past, [a, b, c | rest]), do: resolve_ops(:*, past ++ [a], [b, c | rest])
end

input = File.read!("input/18.txt")

input
|> Eighteen.part_one()
|> IO.inspect()

input
|> Eighteen.part_two()
|> IO.inspect()
