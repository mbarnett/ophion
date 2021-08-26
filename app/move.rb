
Move = Struct.new(:direction, :score)

MOVES = [:up, :down, :left, :right].freeze


def move(board)

  puts "BOARD: #{board}"

  move = MOVES.sample

  { move: move }
end
