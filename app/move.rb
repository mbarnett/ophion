
Move = Struct.new(:direction, :score)

MOVES = [:up, :down, :left, :right].freeze


def move(board)

  log "BOARD: #{board}"

  at = head_loc(board)

  log "AT: #{at}"

  move = MOVES.sample

  resulting_loc = send(move, *at)
  log resulting_loc

  while out_of_bounds?(resulting_loc)
    move = MOVES.sample
    resulting_loc = send(move, *at)
    log resulting_loc
  end

  { move: move }
end

def to_loc(position_hash)
  [position_hash[:x], position_hash[:y]]
end

def head_loc(board)
  me = board[:snakes].select {|snake| snake.name == 'Ophion'}
  to_loc(me[:head])
end

def food_locs(board)
  board[:food].map(&:to_loc)
end

# top left, top right, bottom left, bottom right
def corners(board)
  [[0, board[:height] - 1], [board[:width] - 1, board[:height] - 1], [0,0], [board [:width] -1, 0]]
end

def up(x, y)
  [x, y+1]
end

def down(x, y)
  [x, y-1]
end

def left(x, y)
  [x-1, y]
end

def right(x, y)
  [x+1, y]
end

def out_of_bounds?(x, y)
  (x < 0) || (y < 0)
end
