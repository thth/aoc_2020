defmodule Twelve do
  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce({{0, 0}, 0}, fn cmd, ship_pos ->
      run(cmd, ship_pos)
    end)
    |> elem(0)
    |> manhattan_distance()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.reduce({{0, 0}, {10, 1}}, fn cmd, {ship, waypoint} ->
      run_waypoint(cmd, {ship, waypoint})
    end)
    |> elem(0)
    |> manhattan_distance()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, cmd, n] = Regex.run(~r/(\w)(\d+)/, line)
      {cmd, String.to_integer(n)}
    end)
  end

  defp run({"N", n}, {{x, y}, dir}), do: {{x, y + n}, dir}
  defp run({"S", n}, {{x, y}, dir}), do: {{x, y - n}, dir}
  defp run({"E", n}, {{x, y}, dir}), do: {{x + n, y}, dir}
  defp run({"W", n}, {{x, y}, dir}), do: {{x - n, y}, dir}
  defp run({"L", n}, {pos, dir}), do: {pos, Integer.mod(dir + n, 360)}
  defp run({"R", n}, {pos, dir}), do: {pos, Integer.mod(dir - n, 360)}
  defp run({"F", n}, {{x, y}, 90}), do: {{x, y + n}, 90}
  defp run({"F", n}, {{x, y}, 270}), do: {{x, y - n}, 270}
  defp run({"F", n}, {{x, y}, 0}), do: {{x + n, y}, 0}
  defp run({"F", n}, {{x, y}, 180}), do: {{x - n, y}, 180}

  defp manhattan_distance({x, y}) do
    abs(x) + abs(y)
  end

  #my brain turned off
  defp run_waypoint({"N", n}, {ship, {wx, wy}}), do: {ship, {wx, wy + n}}
  defp run_waypoint({"S", n}, {ship, {wx, wy}}), do: {ship, {wx, wy - n}}
  defp run_waypoint({"E", n}, {ship, {wx, wy}}), do: {ship, {wx + n, wy}}
  defp run_waypoint({"W", n}, {ship, {wx, wy}}), do: {ship, {wx - n, wy}}

  defp run_waypoint({"L", 90}, {ship, {wx, wy}}) when wx >= 0 and wy >= 0, do: {ship, {-abs(wy), abs(wx)}}
  defp run_waypoint({"L", 90}, {ship, {wx, wy}}) when wx <= 0 and wy >= 0, do: {ship, {-abs(wy), -abs(wx)}}
  defp run_waypoint({"L", 90}, {ship, {wx, wy}}) when wx <= 0 and wy <= 0, do: {ship, {abs(wy), -abs(wx)}}
  defp run_waypoint({"L", 90}, {ship, {wx, wy}}) when wx >= 0 and wy <= 0, do: {ship, {abs(wy), abs(wx)}}
  defp run_waypoint({"R", 90}, {ship, {wx, wy}}) when wx >= 0 and wy >= 0, do: {ship, {abs(wy), -abs(wx)}}
  defp run_waypoint({"R", 90}, {ship, {wx, wy}}) when wx <= 0 and wy >= 0, do: {ship, {abs(wy), abs(wx)}}
  defp run_waypoint({"R", 90}, {ship, {wx, wy}}) when wx <= 0 and wy <= 0, do: {ship, {-abs(wy), abs(wx)}}
  defp run_waypoint({"R", 90}, {ship, {wx, wy}}) when wx >= 0 and wy <= 0, do: {ship, {-abs(wy), -abs(wx)}}

  defp run_waypoint({"L", 180}, {ship, {wx, wy}}) when wx >= 0 and wy >= 0, do: {ship, {-abs(wx), -abs(wy)}}
  defp run_waypoint({"L", 180}, {ship, {wx, wy}}) when wx <= 0 and wy >= 0, do: {ship, {abs(wx), -abs(wy)}}
  defp run_waypoint({"L", 180}, {ship, {wx, wy}}) when wx <= 0 and wy <= 0, do: {ship, {abs(wx), abs(wy)}}
  defp run_waypoint({"L", 180}, {ship, {wx, wy}}) when wx >= 0 and wy <= 0, do: {ship, {-abs(wx), abs(wy)}}
  defp run_waypoint({"R", 180}, {ship, {wx, wy}}) when wx >= 0 and wy >= 0, do: {ship, {-abs(wx), -abs(wy)}}
  defp run_waypoint({"R", 180}, {ship, {wx, wy}}) when wx <= 0 and wy >= 0, do: {ship, {abs(wx), -abs(wy)}}
  defp run_waypoint({"R", 180}, {ship, {wx, wy}}) when wx <= 0 and wy <= 0, do: {ship, {abs(wx), abs(wy)}}
  defp run_waypoint({"R", 180}, {ship, {wx, wy}}) when wx >= 0 and wy <= 0, do: {ship, {-abs(wx), abs(wy)}}

  defp run_waypoint({"L", 270}, {ship, {wx, wy}}) when wx >= 0 and wy >= 0, do: {ship, {abs(wy), -abs(wx)}}
  defp run_waypoint({"L", 270}, {ship, {wx, wy}}) when wx <= 0 and wy >= 0, do: {ship, {abs(wy), abs(wx)}}
  defp run_waypoint({"L", 270}, {ship, {wx, wy}}) when wx <= 0 and wy <= 0, do: {ship, {-abs(wy), abs(wx)}}
  defp run_waypoint({"L", 270}, {ship, {wx, wy}}) when wx >= 0 and wy <= 0, do: {ship, {-abs(wy), -abs(wx)}}
  defp run_waypoint({"R", 270}, {ship, {wx, wy}}) when wx >= 0 and wy >= 0, do: {ship, {-abs(wy), abs(wx)}}
  defp run_waypoint({"R", 270}, {ship, {wx, wy}}) when wx <= 0 and wy >= 0, do: {ship, {-abs(wy), -abs(wx)}}
  defp run_waypoint({"R", 270}, {ship, {wx, wy}}) when wx <= 0 and wy <= 0, do: {ship, {abs(wy), -abs(wx)}}
  defp run_waypoint({"R", 270}, {ship, {wx, wy}}) when wx >= 0 and wy <= 0, do: {ship, {abs(wy), abs(wx)}}

  defp run_waypoint({"F", n}, {{sx, sy}, {wx, wy}}), do: {{sx + (n * wx), sy + (n * wy)}, {wx, wy}}
end

input = File.read!("input/12.txt")

input
|> Twelve.part_one()
|> IO.inspect()

input
|> Twelve.part_two()
|> IO.inspect()
