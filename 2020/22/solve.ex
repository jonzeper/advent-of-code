defmodule Game do
  defmacro __using__(_opts) do
    quote do
      def winning_score(game) do
        Enum.at(game.decks, game.last_round_winner)
        |> Enum.reverse
        |> Enum.with_index
        |> Enum.reduce(0, fn {card, i}, score -> score + card * (i+1) end)
      end
    end
  end

  def game_over?(game) do
    game.decks
    |> Enum.any?(&Enum.empty?/1)
  end
end

defmodule BasicGame do
  use Game
  defstruct decks: [], last_round_winner: 0

  def take_turn(game) do
    {next_cards, next_decks} =
      game.decks
      |> Enum.reverse
      |> Enum.reduce({[], []}, fn [card | deck], {next_cards, next_decks} ->
        {[card | next_cards], [deck | next_decks]}
      end)

    winning_card = Enum.max(next_cards)
    winning_player = Enum.find_index(next_cards, fn card -> card == winning_card end)

    next_decks =
      next_decks
      |> List.update_at(winning_player, fn deck -> deck ++ Enum.sort_by(next_cards, fn c -> 0 - c end) end)

    %BasicGame{game | decks: next_decks, last_round_winner: winning_player}
  end

  def play(game) do
    case game_over?(game) do
      true -> game
      false -> game |> take_turn |> play
    end
  end

  def game_over?(game), do: Game.game_over?(game)
end

defmodule RecursiveGame do
  use Game
  defstruct [decks: [], last_round_winner: 0, deck_history: []]

  def take_turn(game) do
    # IO.puts "----------------------------"
    # Enum.each(game.decks, fn deck -> IO.puts(inspect deck) end)
    game = game |> add_decks_to_history
    {next_cards, next_decks} =
      game.decks
      |> Enum.reverse
      |> Enum.reduce({[], []}, fn [card | deck], {next_cards, next_decks} ->
        {[card | next_cards], [deck | next_decks]}
      end)

    winning_player = if should_recurse?(next_cards, next_decks) do
      # IO.puts " --- recurse ---"
      next_decks =
        next_cards
        |> Enum.zip(next_decks)
        |> Enum.map(fn {card, deck} -> Enum.take(deck, card) end)
      (%RecursiveGame{decks: next_decks} |> play).last_round_winner
    else
      winning_card = Enum.max(next_cards)
      Enum.find_index(next_cards, fn card -> card == winning_card end)
    end

    next_decks =
      next_decks
      |> List.update_at(winning_player, fn deck -> deck ++ Enum.sort_by(next_cards, fn c -> c != Enum.at(next_cards, winning_player) end) end)

    %RecursiveGame{game | decks: next_decks, last_round_winner: winning_player}
  end

  def should_recurse?(next_cards, next_decks) do
    next_cards
    |> Enum.zip(next_decks)
    |> Enum.all?(fn {card, deck} -> card <= Enum.count(deck) end)
  end

  def add_decks_to_history(game) do
    %RecursiveGame{game | deck_history: [game.decks | game.deck_history]}
  end

  def history_cycle_detected?(game) do
    x=
    game.deck_history
    |> Enum.any?(fn historical_decks ->
      historical_decks == game.decks
    end)
    # if x, do: IO.puts("History cycle detected!")
    x
  end

  def play(game) do
    if history_cycle_detected?(game) do
      %RecursiveGame{game | last_round_winner: 0}
    else
      case game_over?(game) do
        true -> game
        false -> game |> take_turn |> play
      end
    end
  end

  def game_over?(game) do
    Game.game_over?(game)
  end
end

defmodule Solver do
  def read_decks(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(fn line -> line == "" end)
    |> Stream.map(fn deck -> Enum.drop(deck, 1) end)
    |> Stream.reject(fn deck -> Enum.empty?(deck) end)
    |> Enum.map(fn deck -> Enum.map(deck, &String.to_integer/1) end)
  end

  def solve(filename) do
    %BasicGame{decks: read_decks(filename)}
    |> BasicGame.play
    |> BasicGame.winning_score
  end

  def solve2(filename) do
    initial_decks = read_decks(filename)
    %RecursiveGame{decks: initial_decks, deck_history: []}
    |> RecursiveGame.play
    |> RecursiveGame.winning_score
  end
end

# 306
:timer.tc(Solver, :solve, ["test.txt"]) |> inspect |> IO.puts

# {6851, 33694}
:timer.tc(Solver, :solve, ["input.txt"]) |> inspect |> IO.puts

# 291
:timer.tc(Solver, :solve2, ["test.txt"]) |> inspect |> IO.puts
# :timer.tc(Solver, :solve2, ["infinite-possibility.txt"]) |> inspect |> IO.puts

# {26286799, 31835}
:timer.tc(Solver, :solve2, ["input.txt"]) |> inspect |> IO.puts
