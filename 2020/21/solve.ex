defmodule Food do
  defstruct [ingredients: MapSet.new(), allergens: MapSet.new()]
  def from_str(str) do
    [_, ingredients_str, allergens_str] =
      Regex.run(~r/(.*) \(contains (.*)\)\n/, str)

    %Food{
      ingredients: String.split(ingredients_str, " ") |> Enum.into(MapSet.new()),
      allergens: String.split(allergens_str, ", ") |> Enum.into(MapSet.new())
    }
  end
end

defmodule AllergenMap do
  defstruct [map: %{}, known: []]

  def add_food(agm, food) do
    food.allergens
    |> Enum.reduce(agm, &add_allergen(&2, &1, food.ingredients))
  end

  def get(agm, allergen), do: Map.get(agm.map, allergen)
  def put(agm, allergen, ingredients), do: %AllergenMap{agm | map: Map.put(agm.map, allergen, ingredients)}

  def add_allergen(agm, allergen, ingredients) do
    current = AllergenMap.get(agm, allergen)
    add_allergen(agm, allergen, current, ingredients)
  end
  def add_allergen(agm, allergen, current, ingredients) when current == nil, do: AllergenMap.put(agm, allergen, ingredients)
  def add_allergen(agm, allergen, current, ingredients), do: AllergenMap.put(agm, allergen, MapSet.intersection(current, ingredients))

  def all_possible_allergens(agm) do
    agm.map
    |> Map.values
    |> Enum.reduce(fn allergens, acc -> MapSet.union(allergens, acc) end)
  end

  def deduce_allergens(agm) do
    only_one =
      Enum.filter(agm.map, fn {ag, ings} -> MapSet.size(ings) == 1 end)

    next_known = agm.known ++ Enum.map(only_one, fn {ag, ings} -> {ag, ings |> MapSet.to_list |> List.first} end)

    ings_to_remove = Enum.reduce(only_one, MapSet.new(), fn {_, ings}, acc -> MapSet.union(acc, ings) end)
    ags_to_remove = Enum.map(only_one, fn {ag, _} -> ag end)

    next_agm_map =
      agm.map
      |> Enum.reduce(%{}, fn {ag, ings}, acc ->
        new_ings = MapSet.difference(ings, ings_to_remove)
        if Enum.empty?(new_ings), do: acc, else: Map.put(acc, ag, new_ings)
      end)

    next_agm = %AllergenMap{agm | known: next_known, map: next_agm_map}

    if Enum.empty?(next_agm.map) do
      next_agm
    else
      deduce_allergens(next_agm)
    end
  end
end

defmodule Solver do
  def parse_file(filename) do
    foods =
      File.stream!(filename)
      |> Enum.map(&Food.from_str/1)

    allergen_map =
      Enum.reduce(foods, %AllergenMap{}, fn food, agm -> AllergenMap.add_food(agm, food) end)

    {foods, allergen_map}
  end

  def solve(filename) do
    {foods, allergen_map} = parse_file(filename)

    all_possible_allergens =
      allergen_map
      |> AllergenMap.all_possible_allergens

    foods
    |> Enum.map(fn food -> Enum.into(food.ingredients, []) end)
    |> List.flatten
    |> Enum.reject(fn ing -> Enum.member?(all_possible_allergens, ing) end)
    |> Enum.count
  end

  def solve2(filename) do
    {foods, allergen_map} = parse_file(filename)

    (AllergenMap.deduce_allergens(allergen_map)).known
    |> Enum.sort_by(fn {ag, ing} -> ag end)
    |> Enum.map(fn {_, ing} -> ing end)
    |> Enum.join(",")
  end
end

# 5
:timer.tc(Solver, :solve, ["test.txt"]) |> inspect |> IO.puts

# {5386, 2584}
:timer.tc(Solver, :solve, ["input.txt"]) |> inspect |> IO.puts

# mxmxvkd,sqjhc,fvjkl
:timer.tc(Solver, :solve2, ["test.txt"]) |> inspect |> IO.puts

# {2274, "fqhpsl,zxncg,clzpsl,zbbnj,jkgbvlxh,dzqc,ppj,glzb"}
:timer.tc(Solver, :solve2, ["input.txt"]) |> inspect |> IO.puts
