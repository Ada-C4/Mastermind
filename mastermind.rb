require "colorize"

#############################
# Mastermind game constants #
#############################

# If they haven't guessed after 10 turns, they lose
MAX_TURNS = 10

# Number of pegs in the answer/guesses
NUM_PEGS = 4

# Different game outcomes
GAME_WIN = :win
GAME_LOSE = :lose

# Indicates different kinds of matches
MATCH_EXACT = :exact
MATCH_COLOR = :color
MATCH_NONE = :none

# Our different color options
COLORS = {
  1 => String.color_codes[:red],
  2 => String.color_codes[:light_blue],
  3 => String.color_codes[:green],
  4 => String.color_codes[:yellow],
  5 => String.color_codes[:magenta],
  6 => String.color_codes[:cyan]
}

# Game class
#
# This class represents a single game/match of
# Mastermind. All of the "game state" should be
# managed in this class, including:
# - whether the game has been won, lost, or not yet completed
# - the correct answer
# - each previous guess by the player (or none on the first turn)
#
# Additionally the Game class should have methods for accepting
# new guesses from the player, and methods for the logic used
# in resolving that guess (win/lose/add new previous guess).
class Game

  attr_reader :guesses, :scores, :outcome

  def initialize
    # Initialize game state
    @answer = generate_answer
    @guesses = [] # Start with no guesses
    @scores = [] # Also start with no scores
    @outcome = :unknown # Will be :win or :lose after game is finished
  end

  def generate_answer
    answer = []
    NUM_PEGS.times do
      answer.push(COLORS.keys.shuffle.pop)
    end

    return answer
  end

  def new_guess(guess)
    # First save a copy of the guess in our history
    # We use a copy to avoid accidentally changing the
    # original as we modify the 'guess' variable later
    # in this function
    @guesses.push(guess.dup)

    # Score the guess

    # First we find and remove all exact matches
    result = find_exact_matches(guess)
    guess = result[0]
    exact_matches = result[1]

    # Next we find and remove all color-only matches
    result = find_color_matches(guess)
    guess = result[0]
    color_matches = result[1]

    # The remaining entries in the guess are counted as non-matches
    non_matches = guess.length

    # And now we build our score entry for this guess
    score = build_score(exact_matches, color_matches, non_matches)
    @scores.push(score)

    # Figure out if we've won, lost, or should keep going
    if score.all? { |s| s == MATCH_EXACT }
      # Player wins if they have an exact match for every guess
      @outcome = GAME_WIN
    elsif @guesses.length == MAX_TURNS
      # Player loses if they reach the maximum number of turns
      @outcome = GAME_LOSE
    end
  end

  def find_exact_matches(guess)
    exact_matches = 0
    guess.reject!.with_index do |g, i|
      if g == @answer[i]
        exact_matches += 1
        true # Implicit return -- very important in blocks!
      else
        false # Give back false to indicate we want to keep this for now
      end
    end

    return [guess, exact_matches]
  end

  def find_color_matches(guess)
    # To figure out the color matches we need to track how many of each
    # color there are in the answer.
    # This creates a hash, with a default of 0 instead of nil
    answer_colors = Hash.new(0)
    @answer.each do |a|
      answer_colors[a] += 1
    end

    # Now we can find all the color matches
    color_matches = 0
    guess.reject! do |g|
      # We only count a color match if the answer has that color at least as
      # many times as we've seen that color in the guess already.
      # Example: Three reds in the guess are all color matches if the answer
      # has three or four reds, but only two are matches if the answer has two.
      if answer_colors[g] > 0
        color_matches += 1
        # Decrement the number of this color in our answer
        answer_colors[g] -= 1
        true # Give back true to indicate we want to remove this match
      else
        false # Give back false to indicate we don't want to remove this non-match
      end
    end

    return [guess, color_matches]
  end

  def build_score(exact_matches, color_matches, non_matches)
    score = []
    exact_matches.times do
      score.push(MATCH_EXACT)
    end

    color_matches.times do
      score.push(MATCH_COLOR)
    end

    non_matches.times do
      score.push(MATCH_NONE)
    end

    return score
  end

  def finished?
    @outcome == GAME_WIN || @outcome == GAME_LOSE
  end
end


# Board class
#
# This class represents the actual game board for Mastermind.
# It will be used to display the current game state to the player,
# which it receives from the Game class.
class Board
  def initialize(game)
    @game = game
  end

  def new_display
    display = ""

    # To display the game board we need to
    # - show empty lines for each round that hasn't been played yet
    # - show filled lines for each round that has been played
    # - show any status messages about the game outcome

    # First show empty lines for unplayed rounds
    (MAX_TURNS - @game.guesses.length).times do
      display += empty_line
    end

    # Second show complete lines for each guess
    # We do this in reverse order, as the first guess is @game.guesses[0]
    guesses = @game.guesses.reverse
    scores = @game.scores.reverse
    guesses.length.times do |i|
      display += build_line(guesses[i], scores[i])
    end

    case @game.outcome
    when GAME_WIN
      display += "\nYou Won!"
    when GAME_LOSE
      display += "\nYou lost :("
    end
    display += "\n"

    return display
  end

  def build_line(guess, score)
    line = ""
    line += guess.join(" ")
    line += "  |  "
    score.each do |s|
      case s
      when MATCH_EXACT
        line += "#"
      when MATCH_COLOR
        line += "*"
      when MATCH_NONE
        line += "."
      else
        line += "?"
      end

      line += " "
    end

    line += "\n"
    return line
  end

  def empty_line
    ". " * NUM_PEGS + " |  " + "_ " * NUM_PEGS + "\n"
  end
end


# play_mastermind
#
# This method creates a new Game and Board for Mastermind and
# operates the "game loop" which:
# 1. accepts input from the player
# 2. provides it to the Game object
# 3. gets the display data from the Board object
# 4. prints that display data to the screen
# 5. loops back to step 1. if the game is not yet complete
# 6. OR, quits the program if the game has been won/lost
def play_mastermind
  game = Game.new
  board = Board.new(game)

  # Display the game board once to start
  print board.new_display

  while !game.finished?
    # Accept input from the player
    print "Please enter your guess: "
    guess = gets

    # Sanitize that input
    # by first removing all whitespace from the input
    guess = guess.gsub(/\s+/, "")

    # then we check that we only have four digits, between
    # 1 and 4. If that's not the case, ask for input again.
    if !guess.match(/^[1-#{COLORS.length}]{#{NUM_PEGS}}$/)
      puts "That wasn't a valid guess!"
      next # Skip the rest of this loop
    end

    # Next we tranform it into an array of numbers
    # so the Game class only deals with numbers
    guess = guess.split("").map { |c| c.to_i }

    # Pass it to the game object
    game.new_guess(guess)

    # Print out the new display of the board
    print board.new_display
  end

  puts "Do you want to play again?"
  response = gets.chomp.upcase
  case response
  when "1", "Y", "YES"
    play_mastermind
  else
    puts "Thanks for playing Mastermind!"
    exit
  end
end
