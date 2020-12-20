defmodule Twenty do
  @tile_length 10
  @stripped_tile_length 8
  @map_length 12 * @stripped_tile_length
  @sea_monster """
                      #
    #    ##    ##    ###
     #  #  #  #  #  #
    """
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", x}, inner_acc -> MapSet.put(inner_acc, {x, y})
        _, inner_acc -> inner_acc
      end)
    end)

  # I just realized I'm assuming tile matches are unique
  # oh no
  # ...phew
  def part_one(input) do
    matched_tiles =
      input
      |> parse()
      |> match_tiles()
      |> Enum.into(%{})

    {{min_x, _}, {max_x, _}} =
      matched_tiles
      |> Map.keys()
      |> Enum.min_max_by(fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} =
      matched_tiles
      |> Map.keys()
      |> Enum.min_max_by(fn {_, y} -> y end)

    [{min_x, min_y}, {min_x, max_y}, {max_x, min_y}, {max_x, max_y}]
    |> Enum.map(fn coords ->
      Map.get(matched_tiles, coords)
      |> elem(0)
    end)
    |> Enum.reduce(&*/2)
  end

  # assuming sea monsters don't overlap
  def part_two(input) do
    map =
      input
      |> parse()
      |> match_tiles()
      |> Enum.map(&strip_tile_border_and_n/1)
      |> merge_tiles()

    total_hashes = MapSet.size(map)
    sea_monster_size = MapSet.size(@sea_monster)

    n_sea_monsters =
      for flips <- 0..1,
          cw_rotations <- 0..3 do
        {flips, cw_rotations}
      end
      |> Enum.map(fn orientation ->
        orient_map(map, orientation)
        |> count_sea_monsters()
      end)
      |> Enum.max()

    total_hashes - (n_sea_monsters * sea_monster_size)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn tile_str ->
      [a, b] = String.split(tile_str, "\n", parts: 2)
      tile_n =
        Regex.run(~r/\d+/, a)
        |> List.first()
        |> String.to_integer()

      tile =
        b
        |> String.split("\n")
        |> Enum.with_index()
        |> Enum.reduce(MapSet.new(), fn {line, y}, acc ->
          line
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(acc, fn
            {"#", x}, inner_acc -> MapSet.put(inner_acc, {x, y})
            _, inner_acc -> inner_acc
          end)
        end)

      {tile_n, tile}
    end)
  end

  defp match_tiles([first | rest]), do: do_match([], rest, [{{0, 0}, first}])

  defp do_match([], [], matched), do: matched
  defp do_match(past, [], matched), do: do_match([], past, matched)
  defp do_match(past, [head | rest], matched) do
    match =
      for flips <- 0..1,
          cw_rotations <- 0..3 do
        {flips, cw_rotations}
      end
      |> Enum.find_value(fn orientation ->
        orient_tile(head, orientation)
        |> find_match(matched)
      end)

    case match do
      nil ->
        do_match(past ++ [head], rest, matched)
      {coords, oriented_tile} ->
        do_match(past, rest, [{coords, oriented_tile} | matched])
    end
  end

  defp orient_tile({tile_n, tile}, {flips, cw_rotations}) do
    oriented =
      tile
      |> Stream.iterate(&flip_tile/1)
      |> Enum.at(flips)
      |> Stream.iterate(&cw_rotate_tile/1)
      |> Enum.at(cw_rotations)
    {tile_n, oriented}
  end

  defp flip_tile(tile) do
    tile
    |> Enum.reduce(MapSet.new(), fn {x, y}, acc ->
      MapSet.put(acc, {(@tile_length - 1) - x, y})
    end)
  end

  defp cw_rotate_tile(tile) do
    tile
    |> Enum.reduce(MapSet.new(), fn {x, y}, acc ->
      MapSet.put(acc, {y, x})
    end)
    |> flip_tile()
  end

  defp find_match(_tile, []), do: nil
  defp find_match({tile_n, tile}, [{{x, y}, {_, base}} | rest]) do
    cond do
      match_up?(base, tile)    -> {{x, y - 1}, {tile_n, tile}}
      match_down?(base, tile)  -> {{x, y + 1}, {tile_n, tile}}
      match_left?(base, tile)  -> {{x - 1, y}, {tile_n, tile}}
      match_right?(base, tile) -> {{x + 1, y}, {tile_n, tile}}
      true -> find_match({tile_n, tile}, rest)
    end
  end

  defp match_up?(base, tile) do
    base_up =
      base
      |> Enum.filter(fn {_x, y} -> y == 0 end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.sort()
    tile_down =
      tile
      |> Enum.filter(fn {_x, y} -> y == @tile_length - 1 end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.sort()
    base_up == tile_down
  end

  defp match_down?(base, tile) do
    base_down =
      base
      |> Enum.filter(fn {_x, y} -> y == @tile_length - 1 end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.sort()
    tile_up =
      tile
      |> Enum.filter(fn {_x, y} -> y == 0 end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.sort()
    base_down == tile_up
  end

  defp match_left?(base, tile) do
    base_left =
      base
      |> Enum.filter(fn {x, _y} -> x == 0 end)
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.sort()
    tile_right =
      tile
      |> Enum.filter(fn {x, _y} -> x == @tile_length - 1 end)
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.sort()
    base_left == tile_right
  end

  defp match_right?(base, tile) do
    base_right =
      base
      |> Enum.filter(fn {x, _y} -> x == @tile_length - 1 end)
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.sort()
    tile_left =
      tile
      |> Enum.filter(fn {x, _y} -> x == 0 end)
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.sort()
    base_right == tile_left
  end

  defp strip_tile_border_and_n({coords, {_tile_n, tile}}) do
    stripped =
      tile
      |> Enum.filter(fn {x, y} ->
        x != 0 and x != @tile_length - 1 and y != 0 and y != @tile_length - 1
      end)
      |> Enum.map(fn {x, y} -> {x - 1, y - 1} end)

    {coords, stripped}
  end

  defp merge_tiles(tiles) do
    tiles
    |> Enum.reduce(MapSet.new(), fn {{coord_x_off, coord_y_off}, tile}, acc ->
      Enum.reduce(tile, acc, fn {x, y}, inner_acc ->
        new_point = {x + (coord_x_off * @stripped_tile_length), y + (coord_y_off * @stripped_tile_length)}
        MapSet.put(inner_acc, new_point)
      end)
    end)
  end

  defp orient_map(map, {flips, cw_rotations}) do
    map
    |> Stream.iterate(&flip_map/1)
    |> Enum.at(flips)
    |> Stream.iterate(&cw_rotate_map/1)
    |> Enum.at(cw_rotations)
  end

  defp flip_map(map) do
    map
    |> Enum.reduce(MapSet.new(), fn {x, y}, acc ->
      MapSet.put(acc, {(@map_length - 1) - x, y})
    end)
  end

  defp cw_rotate_map(map) do
    map
    |> Enum.reduce(MapSet.new(), fn {x, y}, acc ->
      MapSet.put(acc, {y, x})
    end)
    |> flip_map()
  end

  defp count_sea_monsters(map) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(map, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(map, fn {_, y} -> y end)

    for x <- min_x..max_x,
        y <- min_y..max_y do
      {x, y}
    end
    |> Enum.count(fn coords -> sea_monster_at_coords?(map, coords) end)
  end

  defp sea_monster_at_coords?(map, {x, y}) do
    @sea_monster
    |> Enum.map(fn {x_off, y_off} -> {x + x_off, y + y_off} end)
    |> Enum.all?(&MapSet.member?(map, &1))
  end
end

input = File.read!("input/20.txt")

input
|> Twenty.part_one()
|> IO.inspect()

input
|> Twenty.part_two()
|> IO.inspect()
