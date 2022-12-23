defmodule Passport do
    @valid_ecl ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    @required_fields [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]
    defstruct [:cid | @required_fields]

    def is_valid(p) do
        shared_keys = MapSet.intersection(MapSet.new(Map.keys(p)), MapSet.new(@required_fields))
                      |> MapSet.to_list
                      |> Enum.filter(fn k -> Map.get(p, k) != nil end)
        Enum.sort(shared_keys) == Enum.sort(@required_fields)
    end

    def is_valid2(p) do
        @required_fields
        |> Enum.all?(fn k -> is_valid_attr(p, k) end)
    end

    def is_valid_attr(p, k) do
        v = Map.get(p, k) || ""
        case k do
            :byr -> Regex.match?(~r/^\d{4}$/, v) && String.to_integer(v) >= 1920 && String.to_integer(v) <= 2002
            :iyr -> Regex.match?(~r/^\d{4}$/, v) && String.to_integer(v) >= 2010 && String.to_integer(v) <= 2020
            :eyr -> Regex.match?(~r/^\d{4}$/, v) && String.to_integer(v) >= 2020 && String.to_integer(v) <= 2030
            :hgt ->
                try do
                    [_, hgt, measure] = Regex.run(~r/(\d+)(.+)/, v)
                    hgt_i = String.to_integer(hgt)
                    case measure do
                        "cm" -> hgt_i >= 150 and hgt_i <= 193
                        "in" -> hgt_i >= 59 and hgt_i <= 76
                        _ -> false
                    end
                rescue
                    MatchError -> false
                end
            :hcl -> Regex.match?(~r/^#[0-9a-f]{6}$/, v)
            :ecl -> Enum.any?(@valid_ecl, fn ecl -> ecl == v end)
            :pid -> Regex.match?(~r/^\d{9}$/, v)
            _ -> true
        end
    end

    def from_string(s) do
        s
        |> String.split(" ")
        |> Enum.map(fn attr -> [k, v] = String.split(attr, ":"); {String.to_atom(k), v} end)
        |> (&struct(Passport, &1)).()
    end
end

defmodule Solver do
    def solve(filename) do
        get_input(filename)
        |> Enum.count(&Passport.is_valid/1)
    end

    def solve2(filename) do
        get_input(filename)
        |> Enum.count(&Passport.is_valid2/1)
    end

    def get_input(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.chunk_by(fn line -> line != "" end)
        |> Stream.filter(fn line -> line != [""] end)
        |> Stream.map(&Enum.join(&1, " "))
        |> Stream.map(&Passport.from_string/1)
    end
end

Solver.solve("test.txt") |> inspect |> IO.puts # 2
Solver.solve("input.txt") |> inspect |> IO.puts # 260

# Solver.solve2("test2.txt") |> inspect |> IO.puts # 4
Solver.solve2("input.txt") |> inspect |> IO.puts # < 154
