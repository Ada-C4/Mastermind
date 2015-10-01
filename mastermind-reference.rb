require "colorize"
class Game
  attr_accessor :board, :rows

  def initialize
    @rows = [[]]
    @board = Board.new(@rows)
  end

  def quit_check(input)
    if "quit" == input
      abort
    end
  end

  def int_check(raw_input)
    int_input = raw_input.to_i
    if int_input == 0 && !(raw_input == "0")
      return false
    else
      return true
    end
  end
end

class Board
  attr_accessor :rows
  def initialize(rows)
    @rows = rows
  end
  def draw_board
    @rows.each do |row|
      puts row.join()
    end
  end
end

class MasterMind < Game
  attr_accessor :guessable_row, :colors, :answer_row, :palatte, :rows, :board, :game_going

  def initialize
    @guessable_row = [". ", ". ", ". ", ". ", " .", ".", ".", "."]
    @colors = {black: "bla", red: "red", green: "gre", yellow: "yel", blue: "blu",
      magenta: "mag", cyan: "cya"}
    @answer_row = populate_answer_row
    @palatte = populate_palatte
    @rows = [["? ? ? ?"], ["-" * 27], @palatte[0], @palatte[1], ["-" * 27]]
    @board = Board.new(@rows)
    @game_going = nil
    start
  end

  def start
    @game_going = true
    puts "Let's play Master Mind!\nTo quit at any time, type the word \"quit\".\nWhat level of difficulty would you like?\n(Choose a number 1-5, 5 being hardest, 1 being easiest.)"
    input = gets.chomp.downcase
    quit_check(input)
    until int_check(input) && (1 .. 5).include?(input.to_i)
      puts "Please type a number between 1 and 5."
      input = gets.chomp.downcase
      quit_check(input)
    end
    (11 - input.to_i).times do
      @rows.insert(1, @guessable_row)
    end
    run
  end

  def run
    while @game_going
      @board.draw_board
      get_a_guess
      if !@rows.include?(@guessable_row)
        @game_going = false
        lose
      end
    end
  end

  def get_a_guess
    guess = []
    while guess.length !=4
      puts "Type in a guess.\n(Type four of the names from the palatte below the board, separated by commas.)"
      input = gets.chomp
      quit_check(input)
      guess = input.split(",")
    end
    guess = guess.map { |word| word.strip}
    result = []
    guess.each do |abbr|
      @colors.each do |color, a|
        if a == abbr
          result << "@ ".colorize(color)
        end
      end
    end
    check_a_guess(result)
  end

  def check_a_guess(guess)
    guess << " "
    white_check = []
    guess.each do |el|
      if !white_check.include?(el)
        white_check.push(el)
      end
    end
    results = []
    (0 .. 3).each do |n|
      if guess[n] == @answer_row[n]
        results << "redpin"
        white_check.delete(guess[n])
      else
        next
      end
    end
    (0 .. white_check.length).each do |n|
      if @answer_row.include?(white_check[n])
        results << "whitepin"
      else
        next
      end
    end
    results.sort
    show_a_guess(guess, results.sort)
  end


  def show_a_guess(guess, evaluation)
    evaluation.each do |e|
      if e == "redpin"
        guess << "˚".colorize(:red)
      elsif e == "whitepin"
        guess << "˚".colorize(:light_black)
      end
    end
    ind = 0
    @rows.reverse!.each do |row|
      if row == @guessable_row
        ind = @rows.index(row)
        break
      else
        next
      end
    end
    @rows[ind] = guess
    @rows.reverse!
    if evaluation == ["redpin", "redpin", "redpin", "redpin"]
      win
    end
  end

  def win
    @game_going = false
    puts "Nice job! You win!"
    @rows[0] = @answer_row
    @board.draw_board
    puts "Play again?"
    input = gets.chomp.downcase
    if input == "yes"
      start
    else
      abort
    end
  end

  def lose
    puts "I'm sorry, you've lost the game."
    @rows[0] = @answer_row
    @board.draw_board
    abort
  end

  def populate_answer_row
    result = []
    until result.length == 4
      color = @colors.keys[rand(0 ... @colors.keys.length)]
      new_peg = "@ ".colorize(color)
      if !result.include?(new_peg)
        result << new_peg
      end
    end
    result
  end

  def populate_palatte
    result = [[],[]]
    @colors.keys.each do |color|
      result[0] << " " + "@".colorize(color) + "  "
      result[1] << @colors[color].colorize(color) + " "
    end
    return result
  end

end

MasterMind.new
