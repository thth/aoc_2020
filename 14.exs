defmodule Fourteen do
  defmodule State do
    defstruct memory: %{}, mask: nil
  end
  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce(%State{}, fn ins, acc -> run(ins, acc) end)
    |> Map.get(:memory)
    |> Enum.map(fn {_address, value} -> value end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse_two()
    |> Enum.reduce(%State{}, fn ins, acc -> run_two(ins, acc) end)
    |> Map.get(:memory)
    |> Enum.map(fn {_address, value} -> value end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      cond do
        line =~ "mask" ->
          mask =
            line
            |> String.split(" ")
            |> List.last()
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.reduce([], fn
              {"1", i}, acc -> [{i, "1"} | acc]
              {"0", i}, acc -> [{i, "0"} | acc]
              {"X", _}, acc -> acc
            end)

          {:mask, mask}
        line =~ "mem" ->
          [_, address, value] = Regex.run(~r/(\d+)] = (\d+)/, line)
          {:mem, String.to_integer(address), String.to_integer(value)}
      end
    end)
  end

  defp run({:mask, mask}, state), do: %State{state | mask: mask}

  defp run({:mem, address, value}, state) do
    masked_value = apply_mask(value, state.mask)

    %State{state |
      memory: Map.put(state.memory, address, masked_value)
    }
  end

  defp apply_mask(value, mask) do
    value
    |> Integer.to_string(2)
    |> String.pad_leading(36, "0")
    |> String.graphemes()
    |> (fn digit_list ->
      Enum.reduce(mask, digit_list, fn {i, digit}, acc ->
        List.replace_at(acc, i, digit)
      end)
    end).()
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp parse_two(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      cond do
        line =~ "mask" ->
          mask =
            line
            |> String.split(" ")
            |> List.last()
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.reduce({[], []}, fn
              {"1", i}, {acc_1, acc_x} -> {[i | acc_1], acc_x}
              {"X", i}, {acc_1, acc_x} -> {acc_1, [i | acc_x]}
              {"0", _}, acc -> acc
            end)

          {:mask, mask}
        line =~ "mem" ->
          [_, address, value] = Regex.run(~r/(\d+)] = (\d+)/, line)
          {:mem, String.to_integer(address), String.to_integer(value)}
      end
    end)
  end

  defp run_two({:mask, mask}, state), do: %State{state | mask: mask}

  defp run_two({:mem, address, value}, state) do
    new_memory =
      all_addresses(address, state.mask)
      |> Enum.reduce(state.memory, fn one_address, acc ->
        Map.put(acc, one_address, value)
      end)

    %State{state | memory: new_memory}
  end

  defp all_addresses(address, {one_list, x_list}) do
    oned_address =
      address
      |> Integer.to_string(2)
      |> String.pad_leading(36, "0")
      |> String.graphemes()
      |> (fn digits ->
        Enum.reduce(one_list, digits, fn i, acc ->
          List.replace_at(acc, i, "1")
        end)
      end).()

    x_list
    |> Enum.reduce([oned_address], fn i, acc ->
      Enum.reduce(acc, [], fn a, inner_acc ->
        [List.replace_at(a, i, "0"), List.replace_at(a, i, "1")] ++ inner_acc
      end)
    end)
    |> Enum.map(fn digits ->
      digits
      |> Enum.join()
      |> String.to_integer(2)
    end)
  end
end

input = File.read!("input/14.txt")

input
|> Fourteen.part_one()
|> IO.inspect()

input
|> Fourteen.part_two()
|> IO.inspect()
