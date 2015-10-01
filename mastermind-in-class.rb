require "colorize"

# class Board
#   attr_accessor :rows
#   def initialize(rows)
#     @rows = rows
#   end
#   def draw_board
#     @rows.each do |row|
#       puts row.join()
#     end
#   end
# end

class Mastermind
  # Let's add some accessors!
  attr_accessor :rows

  # Constructor for our Mastermind class
  def initialize
    # Default initialization for board constructs
    @default_rows = 11
    # @rows = [[]]

    # Default data stuff
    @blank_row = [". ", ". ", ". ", ". ", ".", ".", ".", "."]
    @color_choices = {black: "bla", red: "red", green: "gre", yellow: "yel", blue: "blu",
      magenta: "mag", cyan: "cya"}

    # Initialize the game stuff
    @color_palette = get_palette
    @rows = [["? ? ? ?"], ["-" * 27], @color_palette, ["-" * 27]]
    @now_playing = false

    # Start the game!
    start
  end

  def start
    # Create the initial state for the game to be played!
    puts "Let's play Mastermind!"
    @now_playing = true
    @answer_row = populate_answer_row

    # Insert all of the blank rows for initialization
    @default_rows.times do
      @rows.insert(1, @blank_row)
    end

    # Now lets play the game
    play
  end

  def play
    while @now_playing
      draw_board
      get_guess
    end
  end

# --------------------------------------------------------------
# User checks!

  # If the user enters quit - exit the program
  def quit_check(input)
    if input == "quit"
      abort
    end
  end

  # Ensure the user enters integers when desired
  # def int_check(raw_input)
  #   int_input = raw_input.to_i
  #   if int_input == 0 && !(raw_input == "0")
  #     return false
  #   else
  #     return true
  #   end
  # end

# --------------------------------------------------------------
# Guess stuff!

  def get_guess
    # initialize my variables
    guess = []
    result = []

    # Continue getting input until there are the valid #s
    while guess.length != 4
      puts "Type in a guess.\n(Type four of the names from the palatte below the board, separated by commas.)"
      input = gets.chomp
      quit_check(input)
      guess = input.split(",")
    end

    guess.each do |guess_color|
      @color_choices.each do |color, color_abbr|
        if guess_color == color_abbr
          # Create a result that contains the colored guesses
          result.push("@ ".colorize(color))
        end
      end
    end

    # Now that we have constructed the guess, let's check it
    check_guess(result)
  end

  def check_guess(guess)
    exact_match = 0
    color_match = 0

    guess_copy = guess.dup

    # Check for the exact match within the guess
    (0..3).each do |n|
      if guess[n] == @answer_row[n]
        exact_match += 1
        guess_copy.delete(guess[n])
      end
    end
    puts guess_copy
    # Check for a color match within the guess
    guess_copy.each do |color_guess|
      if @answer_row.include?(color_guess)
        color_match += 1
      end
    end

    # Display guess
    display_guess(guess, exact_match, color_match)
  end


# --------------------------------------------------------------
# Visual methods

  # Output each row for the user
  def draw_board
    @rows.each do |row|
      puts row.join()
    end
  end

  def display_guess(guess, exact_match, color_match)
    # Create the exact match
    exact_match.times do
      guess.push(".".colorize(:red))
    end

    # Create the partial match
    color_match.times do
      guess.push(".".colorize(:light_yellow))
    end

    # Add the blank items
    (4 - exact_match - color_match).times do
      guess.push(".")
    end

    # Find the last guessable row to update
    index = @rows.length - 1
    while index >= 0
      if @rows[index] == @blank_row
        @rows[index] = guess

        # Done out of the loop
        index = -1
      end

      index -= 1
    end
  end

  def get_palette
      palette = []
      @color_choices.each do |color_name, short_name|
        palette.push(short_name.colorize(color_name))
      end
      return palette
  end

# --------------------------------------------------------------
# Winning and Losing!!!!

  def populate_answer_row
    result = []
    until result.length == 4
      # Get a random color
      random_color = @color_choices.keys[rand(0 ... @color_choices.keys.length)]
      new_peg = "@ ".colorize(random_color)
      result.push(new_peg)
    end

    puts "ANSWER: " + result.join

    return result
  end

  def win
  end

  def lose
  end
end
