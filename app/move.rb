
Move = Struct.new(:direction, :score)

MOVES = [:up, :down, :left, :right].freeze


def move(board)

  puts board

  move = MOVES.sample

  puts "MOVE: " + move

  { move: move }
end
