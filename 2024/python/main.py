import importlib
import os

import typer
import yaml

import timeit


def run_part(day: int, part: int = 1, bench: int = 0):
    day_str = f"{int(day):02d}"
    test_cases = get_test_cases(day_str, part)
    s = importlib.import_module(f"solutions.{day_str}")
    if part == 1:
        prep_func = getattr(s, "part_one_prep", None)
        run_func = s.part_one
    else:
        prep_func = getattr(s, "part_two_prep", None)
        run_func = s.part_two
    for input, expected_result in test_cases.items():
        input_lines = get_input_lines(day_str, input)
        prepped_input = prep_func(input_lines) if prep_func else input_lines
        result = run_func(prepped_input)
        shouldbe = f"(should be {expected_result})" if result != expected_result else ""
        if bench:
            elapsed = timeit.timeit(lambda: run_func(prepped_input), number=bench)
            print(f"{input}: {result} {shouldbe} (Ran {bench} times in {elapsed}s)")
        else:
            print(f"{input}: {result} {shouldbe}")


def get_test_cases(day_str: int, part: int):
    here = os.path.abspath(os.path.dirname(__file__))
    with open(f"{here}/../../inputs/2024/{day_str}/test.yaml") as f:
        data = yaml.safe_load(f)
        return data[f"part_{part}"]


def get_input_lines(day_str: str, key: str) -> list[str]:
    here = os.path.abspath(os.path.dirname(__file__))
    if key.endswith(".txt"):
        input = open(f"{here}/../../inputs/2024/{day_str}/{key}").read()
        if "\n" in input:
            input = input.split("\n")
            return list(filter(lambda x: x != "", input))
    else:
        return [key]



app = typer.Typer()

# Usage
# Run both parts of day 1: `pixi run main 1`
# Run just part two of day 12: `pixi run main 2 12`
# Run both parts of day 1 and benchmark 10k repetitions: `pixi run main 1 --bench 10000`
@app.command()
def run(day: int, part: int = 0, bench: int = 0):
    if part == 0:
        print("-- part one --")
        run_part(day, 1, bench)
        print("-- part two --")
        run_part(day, 2, bench)
    else:
        run_part(day, part, bench)


if __name__ == "__main__":
    app()
